<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { toast } from 'vue3-toastify'
import 'vue3-toastify/dist/index.css'
import instance from '../composables/api'

const router = useRouter()
const email = ref('')
const password = ref('')
const signInText = ref('Sign In')
const isLoading = ref(false)

function login() {
  isLoading.value = true
  signInText.value = 'Loading'
  const userInformation = {
    mail: email.value,
    password: password.value,
  }
  instance.post('login', userInformation).then((response) => {
    isLoading.value = false
    signInText.value = 'Sign In'

    const user = response.data.user // Stockez les données de l'utilisateur
    const token = response.data.token // Stockez le token JWT
    const expirationDate = Date.now() + 3600 * 3000 // Exemple: 3 heures d'expiration (3600 secondes * 3000 ms)

    sessionStorage.setItem('userId', user.id)
    sessionStorage.setItem('expirationDate', expirationDate.toString())
    sessionStorage.setItem('token', token)
    sessionStorage.setItem('role', user.role)
    sessionStorage.setItem('fullname', `${user.firstname} ${user.lastname}`)

    // Configurez Axios pour inclure le token JWT dans les en-têtes pour les requêtes ultérieures
    instance.defaults.headers.common.Authorization = `Bearer ${token}`
    router.push('/dashboard')
  }).catch((error) => {
    isLoading.value = false
    signInText.value = 'Sign In'
    console.error('Authentication failed', error)
    toast.error('Authentication failed', {
      autoClose: 1000,
    })
  })
}
</script>

<template>
  <div class="flex items-center justify-center h-screen px-6 bg-gray-200">
    <div class="w-full max-w-sm p-6 bg-white rounded-md shadow-md">
      <div class="flex items-center justify-center">
        <svg
          class="w-10 h-10"
          viewBox="0 0 512 512"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M364.61 390.213C304.625 450.196 207.37 450.196 147.386 390.213C117.394 360.22 102.398 320.911 102.398 281.6C102.398 242.291 117.394 202.981 147.386 172.989C147.386 230.4 153.6 281.6 230.4 307.2C230.4 256 256 102.4 294.4 76.7999C320 128 334.618 142.997 364.608 172.989C394.601 202.981 409.597 242.291 409.597 281.6C409.597 320.911 394.601 360.22 364.61 390.213Z"
            fill="#4C51BF"
            stroke="#4C51BF"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
          <image href="../../public/time-watch-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
        </svg>
        <span class="text-2xl font-semibold text-gray-700 m-2">Time Manager</span>
      </div>

      <form class="mt-4" @submit.prevent="login">
        <label class="block">
          <span class="text-sm text-gray-700">Email</span>
          <input
            v-model="email"
            type="email"
            class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
          >
        </label>

        <label class="block mt-3">
          <span class="text-sm text-gray-700">Password</span>
          <input
            v-model="password"
            type="password"
            class="block w-full mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
          >
        </label>

        <div class="flex items-center justify-between mt-4">
          <!-- <div>
            <label class="inline-flex items-center">
              <input type="checkbox" class="text-indigo-600 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500">
              <span class="mx-2 text-sm text-gray-600">Remember me</span>
            </label>
          </div> -->

          <!-- <div>
            <a
              class="block text-sm text-indigo-700 fontme hover:underline"
              href="#"
            >Forgot your password?</a>
          </div> -->
        </div>

        <div class="mt-6">
          <button
            :disabled="isLoading"
            class="w-full px-4 py-2 text-sm text-center text-white bg-indigo-600 rounded-md focus:outline-none hover:bg-indigo-500"
          >
            <img v-if="isLoading" class="inline-flex items-center space-x-2 h-4 w-4 mb-1 mr-1" src="../../public/oval.svg" alt="Loading icon">
            {{ signInText }}
          </button>
        </div>
        <hr class="m-3">
      </form>
      <div>
        <button
          class="w-full px-4 py-2 text-sm text-center text-white bg-green-600 rounded-md focus:outline-none hover:bg-green-500"
          @click="router.push('/register')"
        >
          Create Account
        </button>
      </div>
    </div>
  </div>
</template>
