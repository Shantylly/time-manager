<script setup lang="ts">
import { onMounted, ref } from 'vue';
import Datepicker from '../components/Datepicker.vue';
import Loading from '../components/Loading.vue';
import instance from '../composables/api';

const pageLoading = ref(false)
const id = sessionStorage.getItem('userId')

const timespents = ref([])
const clock_status = ref()

onMounted(async () => {
  pageLoading.value = true
  if (id) {
    const response = await instance.get(`timespents/${id}`)
    timespents.value = response.data.timespents
    const response_clock = await instance.get(`/clock_status/${id}`)
    clock_status.value = response_clock.data.status
    pageLoading.value = false
  }
})

let onPhone = false;
if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
  onPhone = true;
}

</script>

<template>
  <div v-if="!pageLoading" class="flex px-6 bg-gray-200">
    <div class="w-full p-6 bg-white rounded-md shadow-md">
      <button v-if="onPhone" class="text-gray-700 hover:text-indigo-600 focus:outline-none focus:text-indigo-600">
          <router-link to="/dashboard">
            <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <image href="../../public/back-arrow-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
            </svg>
          </router-link>
      </button>
      <div class="flex items-center justify-between border-b-4 border-indigo-600 pb-5">
        <h1 class="text-2xl font-semibold text-gray-700 m-2 flex-1">
          TIME MANAGEMENT
        </h1>
        <svg
          class="w-10 h-10"
          viewBox="0 0 512 512"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <image href="../../public/time-watch-svgrepo-com.svg" x="0" y="0" height="100%" width="100%" />
        </svg>
      </div>
      <Datepicker :timespents="timespents" :clockstatus="clock_status" />
    </div>
  </div>
  <div v-else>
    <Loading />
  </div>
</template>
