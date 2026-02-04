import Auth from '../api/auth';

const parseErrorCode = error => Promise.reject(error);

export default axios => {
  const { apiHost = '' } = window.chatwootConfig || {};
  const wootApi = axios.create({ baseURL: `${apiHost}/` });
  // Add Auth Headers from cookie on every request (covers login after page load)
  wootApi.interceptors.request.use(config => {
    if (Auth.hasAuthCookie()) {
      const authData = Auth.getAuthData();
      if (authData && typeof authData === 'object') {
        Object.assign(config.headers, {
          'access-token': authData['access-token'],
          'token-type': authData['token-type'] || 'Bearer',
          client: authData.client,
          expiry: authData.expiry,
          uid: authData.uid,
        });
      }
    }
    return config;
  });
  // Response parsing interceptor
  wootApi.interceptors.response.use(
    response => response,
    error => parseErrorCode(error)
  );
  return wootApi;
};
