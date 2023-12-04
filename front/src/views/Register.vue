<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { toast } from 'vue3-toastify'
import 'vue3-toastify/dist/index.css'
import instance from '../composables/api'
import type { UserInformation } from '../composables/user'

const router = useRouter()
const email = ref('')
const password = ref('')
const confirm_password = ref('')
const address = ref('')
const first_name = ref('')
const last_name = ref('')
const phone_number = ref('')
const isLoading = ref(false)
const selectedGenre = ref('H')

function register() {
  if (!email.value || !password.value || !confirm_password.value || !address.value || !first_name.value || !last_name.value || !phone_number.value) {
    toast.error('Fields are not all completed', {
      autoClose: 1000,
    })
    return
  }
  if (password.value !== confirm_password.value) {
    toast.error('Passwords are not matching', {
      autoClose: 1000,
    })
    return
  }
  isLoading.value = !isLoading.value
  const user: UserInformation = {
    address: address.value,
    role: 'User',
    mail: email.value,
    firstname: first_name.value,
    lastname: last_name.value,
    phone: phone_number.value,
    password: password.value,
    genre: selectedGenre.value,
  }
  instance.post('/users', user)
    .then((response) => {
      isLoading.value = !isLoading.value
      const user = response.data.user // Stockez les données de l'utilisateur
      const token = response.data.token // Stockez le token JWT
      const expirationDate = Date.now() + 3600 * 3000 // Exemple: 1 heure d'expiration (3600 secondes * 1000 ms)

      sessionStorage.setItem('userId', user.id)
      sessionStorage.setItem('expirationDate', expirationDate.toString())
      sessionStorage.setItem('token', token)
      sessionStorage.setItem('role', user.role)
      sessionStorage.setItem('fullname', `${user.firstname} ${user.lastname}`)

      // Configurez Axios pour inclure le token JWT dans les en-têtes pour les requêtes ultérieures
      instance.defaults.headers.common.Authorization = `Bearer ${token}`
      router.push('/dashboard')
    })
    .catch((error) => {
      isLoading.value = !isLoading.value
      if (error) {
        toast.error('Phone or Email already used', {
          autoClose: 1000,
        })
      }
    })
}
</script>

<template>
  <div class="flex items-center justify-center bg-gray-200">
    <div class="w-full md:w-2/4 px-6 bg-white rounded-md shadow-md">
      <div class="flex items-center justify-between border-b-4 border-indigo-600 pb-5">
        <span class="text-2xl font-semibold text-gray-700 m-2 flex-1">Create an account</span>
        <svg class="w-10 h-10" viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg">
          <image href="../../public/time-watch-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
        </svg>
      </div>
      <div class="flex items-center justify-center">
        <form class="mt-4 w-full md:w-3/4" @submit.prevent="register">
          <div class="flex items-center space-x-4 mb-3">
            <label class="flex items-center block mt-3">
              <input
                v-model="selectedGenre"
                type="radio"
                class="w-5 h-5 text-indigo-600 focus:ring-indigo-500"
                name="radio" value="H"
              ><span class="text-sm text-gray-700 pl-2">Male</span>
            </label>
            <label class="flex items-center block mt-3">
              <input
                v-model="selectedGenre"
                type="radio"
                class="w-5 h-5 text-indigo-600 focus:ring-indigo-500"
                name="radio" value="F"
              ><span class="text-sm text-gray-700 pl-2">Female</span>
            </label>
            <label class="flex items-center block mt-3">
              <input
                v-model="selectedGenre"
                type="radio"
                class="w-5 h-5 text-indigo-600 focus:ring-indigo-500"
                name="radio" value="N"
              ><span class="text-sm text-gray-700 pl-2">Other</span>
            </label>
          </div>
          <label class="block mt-3">
            <span class="text-sm text-gray-700">First Name *</span>
            <input
              v-model="first_name"
              type="text"
              class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
            >
          </label>

          <label class="block mt-3">
            <span class="text-sm text-gray-700">Last Name *</span>
            <input
              v-model="last_name"
              type="text"
              class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
            >
          </label>
          <label class="block">
            <span class="text-sm text-gray-700">Email (has to be a valid mail)*</span>
            <input
              v-model="email"
              type="email"
              class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
            >
          </label>

          <label class="block mt-3">
            <span class="text-sm text-gray-700">Password *</span>
            <input
              v-model="password"
              type="password"
              class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
            >
          </label>

          <label class="block mt-3">
            <span class="text-sm text-gray-700">Confirm Password *</span>
            <input
              v-model="confirm_password"
              type="password"
              class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
            >
          </label>

          <label class="block mt-3">
            <span class="text-sm text-gray-700">Address *</span>
            <input
              v-model="address"
              type="text"
              class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
            >
          </label>
          <label class="block mt-3">
            <span class="text-sm text-gray-700">Phone Number (has to be 10 digit)*</span>
            <input
              id="phone"
              v-model="phone_number" type="tel" name="phone" pattern="[0-9]{10}"
              class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
            >
          </label>
          <div class="flex items-center justify-center">
            <div class="flex m-5 w-auto">
              <button
                class="flex-1 m-1 px-4 py-2 font-medium tracking-wide text-white capitalize transition-colors duration-200 transform bg-red-600 rounded-md hover:bg-red-500 focus:outline-none focus:bg-red-500"
                @click="router.push('/')"
              >
                Back
              </button>
              <button
                class="flex-1 m-1 px-4 py-2 font-medium tracking-wide text-white capitalize transition-colors duration-200 transform bg-indigo-600 rounded-md hover:bg-indigo-500 focus:outline-none focus:bg-indigo-500"
              >
                <img v-if="isLoading" class="inline-flex items-center space-x-2 h-4 w-4 mb-1 mr-1" src="../../public/oval.svg" alt="Loading icon">
                {{ isLoading ? 'Loading' : 'Register' }}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
