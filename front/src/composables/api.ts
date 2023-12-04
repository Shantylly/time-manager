
import axios from 'axios';

const instance = axios.create({
  baseURL: 'https://time-manager-hyogo.gigalixirapp.com/api/',
});

export default instance