# TODO: logic is written tailored to contact import since its the only import available
# let's break this logic and clean this up in future

class DataImportJob < ApplicationJob
  queue_as :low
  retry_on ActiveStorage::FileNotFoundError, wait: 1.minute, attempts: 3

  def perform(data_import)
    @data_import = data_import
    @contact_manager = DataImport::ContactManager.new(@data_import.account)
    begin
      process_import_file
    rescue CSV::MalformedCSVError => e
      handle_csv_error(e)
    rescue DataImport::AllRowsInvalidError
      raise
    end
  end

  private

  def process_import_file
    @data_import.update!(status: :processing)
    contacts, rejected_contacts, contact_tags = parse_csv_and_build_contacts

    if contacts.empty? && rejected_contacts.any?
      msg = I18n.t('errors.contacts.import.no_valid_records')
      @data_import.update!(status: :failed, processing_errors: msg)
      raise DataImport::AllRowsInvalidError, msg
    end

    import_contacts(contacts)
    apply_tags_to_contacts(contacts, contact_tags)
    update_data_import_status(contacts.length, rejected_contacts.length)
    save_failed_records_csv(rejected_contacts)
  end

  def parse_csv_and_build_contacts
    contacts = []
    rejected_contacts = []
    contact_tags = []

    with_import_file do |file|
      csv_reader(file).each do |row|
        normalized = normalize_csv_row(row.to_h)
        tag_value = normalized[:tag].to_s.strip.presence
        current_contact = @contact_manager.build_contact(normalized.except(:tag))
        if current_contact.valid?
          contacts << current_contact
          contact_tags << tag_value
        else
          append_rejected_contact(row, current_contact, rejected_contacts)
        end
      end
    end

    [contacts, rejected_contacts, contact_tags]
  end

  CSV_HEADER_MAP = {
    'nome' => :name,
    'name' => :name,
    'first_name' => :first_name,
    'last_name' => :last_name,
    'telefone' => :phone_number,
    'phone_number' => :phone_number,
    'cidade' => :city,
    'city' => :city,
    'país' => :country,
    'pais' => :country,
    'country' => :country,
    'nome da empresa' => :company_name,
    'nome empresa' => :company_name,
    'company_name' => :company_name,
    'company' => :company_name,
    'tag' => :tag,
    'label' => :tag
  }.freeze

  def normalize_csv_row(row_hash)
    row_hash.with_indifferent_access.transform_keys do |key|
      CSV_HEADER_MAP[key.to_s.strip.downcase] || key
    end.compact
  end

  def apply_tags_to_contacts(contacts, contact_tags)
    contacts.each_with_index do |contact, i|
      next if contact_tags[i].blank?

      contact.add_labels([contact_tags[i]])
    end
  end

  def append_rejected_contact(row, contact, rejected_contacts)
    row['errors'] = contact.errors.full_messages.join(', ')
    rejected_contacts << row
  end

  def import_contacts(contacts)
    # <struct ActiveRecord::Import::Result failed_instances=[], num_inserts=1, ids=[444, 445], results=[]>
    Contact.import(contacts, synchronize: contacts, on_duplicate_key_ignore: true, track_validation_failures: true, validate: true, batch_size: 1000)
  end

  def update_data_import_status(processed_records, rejected_records)
    @data_import.update!(status: :completed, processed_records: processed_records, total_records: processed_records + rejected_records)
  end

  def save_failed_records_csv(rejected_contacts)
    csv_data = generate_csv_data(rejected_contacts)
    return if csv_data.blank?

    @data_import.failed_records.attach(io: StringIO.new(csv_data), filename: "#{Time.zone.today.strftime('%Y%m%d')}_contacts.csv",
                                       content_type: 'text/csv')
  end

  def generate_csv_data(rejected_contacts)
    headers = csv_headers
    headers << 'errors'
    return if rejected_contacts.blank?

    CSV.generate do |csv|
      csv << headers
      rejected_contacts.each do |record|
        csv << record
      end
    end
  end

  def handle_csv_error(error)
    @data_import.update!(status: :failed, processing_errors: error.message)
  end

  def csv_headers
    header_row = nil
    with_import_file do |file|
      header_row = csv_reader(file).first
    end
    header_row&.headers || []
  end

  def csv_reader(file)
    file.rewind
    raw_data = file.read
    utf8_data = raw_data.force_encoding('UTF-8')
    clean_data = utf8_data.valid_encoding? ? utf8_data : utf8_data.encode('UTF-16le', invalid: :replace, replace: '').encode('UTF-8')

    CSV.new(StringIO.new(clean_data), headers: true)
  end

  def with_import_file
    temp_dir = Rails.root.join('tmp/imports')
    FileUtils.mkdir_p(temp_dir)

    @data_import.import_file.open(tmpdir: temp_dir) do |file|
      file.binmode
      yield file
    end
  end
end
