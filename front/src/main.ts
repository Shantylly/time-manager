import VueDatePicker from '@vuepic/vue-datepicker'
import '@vuepic/vue-datepicker/dist/main.css'
import { createApp } from 'vue'
import App from './App.vue'
import './assets/main.css'
import DashboardLayout from './components/DashboardLayout.vue'
import EmptyLayout from './components/EmptyLayout.vue'
import router from './router'

const app = createApp(App)

app.component('DefaultLayout', DashboardLayout)
app.component('EmptyLayout', EmptyLayout)

app.component('VueDatePicker', VueDatePicker)
app.use(router)
app.mount('#app')
