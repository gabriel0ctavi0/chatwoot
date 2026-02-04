import { required, minLength } from '@vuelidate/validators';

export const validTagCharacters = (str = '') => !!str && !str.includes(' ');

export const getTagTitleErrorMessage = validation => {
  let errorMessage = '';
  if (!validation.title.$error) {
    errorMessage = '';
  } else if (!validation.title.required) {
    errorMessage = 'TAG_MGMT.FORM.NAME.REQUIRED_ERROR';
  } else if (!validation.title.minLength) {
    errorMessage = 'TAG_MGMT.FORM.NAME.MINIMUM_LENGTH_ERROR';
  } else if (!validation.title.validTagCharacters) {
    errorMessage = 'TAG_MGMT.FORM.NAME.VALID_ERROR';
  }
  return errorMessage;
};

export default {
  title: {
    required,
    minLength: minLength(2),
    validTagCharacters,
  },
  description: {},
  color: {
    required,
  },
  showOnSidebar: {},
};
