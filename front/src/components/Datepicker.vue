<script setup lang="ts">
import { addHours, addMinutes, differenceInMilliseconds, format, isAfter, parseISO, startOfDay, subDays, subHours, subSeconds } from 'date-fns'
import { onMounted, ref } from 'vue'
import { toast } from 'vue3-toastify'
import 'vue3-toastify/dist/index.css'
import instance from '../composables/api'
import router from '../router'

const props = defineProps({
  timespents: Array<Timespent>,
  clockstatus: Boolean,
})

const alreadyClocked = ref(false)

const saveNeeded = ref(false)

const selectedDate = ref(new Date())

interface Day {
  start: string | null
  end: string | null
  duration: string | null
  dateStr: string
  date: Date
}

interface Timespent {
  id: number
  description: string
  date_start: string
  date_end: string
  user_id: string
}

const weekDays = ref<Day[]>([])

const clockedIn = ref(false)

const isLoading = ref(false)

async function fetchWeek() {
  isLoading.value = true
  weekDays.value = []
  for (let i = 0; i < 7; i++) {
    const date = subDays(selectedDate.value, 6 - i)
    const formatDate = `${format(date as Date, 'eee')} ${format(date as Date, 'dd')}/${format(date as Date, 'MM')}/${format(date as Date, 'yy')}`
    const id = checkDayAlreadyUsed(`${formatDate} Work time`)
    const dateStart = id && props.timespents ? parseISO((props.timespents?.find(ts => ts && ts.id === id) as Timespent).date_start) : null
    const dateEnd = id ? parseISO((props.timespents?.find(ts => ts && ts.id === id) as Timespent).date_end) : null
    weekDays.value.push({
      start: id && dateStart ? `${format(dateStart, 'HH:mm')}` : null,
      end: id && dateEnd ? `${format(dateEnd, 'HH:mm')}` : null,
      duration: id && dateEnd && dateStart ? `${format(subHours(new Date(differenceInMilliseconds(dateEnd, dateStart)), 1), 'HH:mm')}` : null,
      dateStr: formatDate,
      date,
    })
  }
  if (weekDays.value[6].date.getDate() === new Date().getDate() && weekDays.value[6].start)
    alreadyClocked.value = true
  isLoading.value = false
}

onMounted(async () => {
  fetchWeek()
  clockedIn.value = props.clockstatus
})

function goToPreviousWeek() {
  const newDate = new Date(selectedDate.value)
  newDate.setDate(newDate.getDate() - 7)
  selectedDate.value = newDate
  fetchWeek()
}

function goToNextWeek() {
  const newDate = new Date(selectedDate.value)
  newDate.setDate(newDate.getDate() + 7)
  selectedDate.value = newDate
  fetchWeek()
}

function goToToday() {
  selectedDate.value = new Date()
  fetchWeek()
}

async function clock() {
  isLoading.value = true
  if (clockedIn.value) {
    const response = await instance.post(`/clock_out/${sessionStorage.getItem('userId')}`)
    const maxTimeClock = 12 * 60 * 60
    if (response.data.time_spent < maxTimeClock) {
      const dateEnd = new Date()
      const dateStart = subSeconds(dateEnd, response.data.time_spent)
      weekDays.value[6].start = `${format(dateStart, 'HH:mm')}`
      weekDays.value[6].end = `${format(dateEnd, 'HH:mm')}`
      save()
    }
    else {
      toast.error('Clock not valid (12 hours max)', {
        autoClose: 1000,
      })
    }
  }
  else {
    await instance.post(`/clock_in/${sessionStorage.getItem('userId')}`)
    isLoading.value = false
  }
  clockedIn.value = !clockedIn.value
}

function checkDayAlreadyUsed(description: string): number {
  if (props.timespents) {
    for (let i = 0; i < props.timespents.length; i++) {
      const element = props.timespents[i] as { description: string; id: number }
      if (element.description === description)
        return element.id
    }
  }
  return 0
}

async function save() {
  isLoading.value = true
  const id = sessionStorage.getItem('userId')
  for (let i = 0; i < weekDays.value.length; i++) {
    let end = null
    let start = null
    const element = weekDays.value[i] as Day

    const hours = element.start?.toString().split(':')[0]
    let minutes = element.start?.toString().split(':')[1]
    minutes = minutes || '00'
    if (hours && minutes)
      start = element.date ? addMinutes(addHours(startOfDay(element.date), Number(hours)), Number(minutes)) : null

    const hours_end = element.end?.toString().split(':')[0]
    let minutes_end = element.end?.toString().split(':')[1]
    minutes_end = minutes || '00'
    if (hours_end && minutes_end)
      end = element.date ? addMinutes(addHours(startOfDay(element.date), Number(hours_end)), Number(minutes_end)) : null

    if (id && start && end) {
      if (!isAfter(start, end)) {
        const putId = checkDayAlreadyUsed(`${element.dateStr} Work time`)
        const timespent: Timespent = {
          id: putId,
          description: `${element.dateStr} Work time`,
          date_start: start?.toISOString(),
          date_end: end?.toISOString(),
          user_id: id,
        }
        if (putId)
          await instance.patch(`timespents/${putId}`, { date_start: start?.toISOString(), date_end: end?.toISOString() })

        else
          await instance.post('/timespents', timespent)
      }
      else {
        toast.error('Date of start after date of end : ' + `${element.dateStr}`, {
          autoClose: 1000,
        })
      }
    }
  }
  isLoading.value = false
  saveNeeded.value = false
  router.go(0)
}

let onPhone = false
if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))
  onPhone = true
</script>

<template>
  <div class="flex flex-col items-center mt-8">
    <div class="flex items-center space-x-4">
      <VueDatePicker v-if="!onPhone" v-model="selectedDate" :disabled="isLoading" :class="isLoading ? 'cursor-not-allowed' : ''" @closed="fetchWeek()" />
      <button v-if="!onPhone" class="text-white px-4 py-2 rounded" :disabled="isLoading || saveNeeded" :class="isLoading || saveNeeded ? 'cursor-not-allowed bg-gray-300' : 'bg-indigo-500 '" @click="goToPreviousWeek">
        <svg
          class="h-4 w-4 inline-block -mt-1" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
      </button>
      <button v-if="!onPhone" class="text-white px-4 py-2 rounded" :disabled="isLoading || saveNeeded" :class="isLoading || saveNeeded ? 'cursor-not-allowed bg-gray-300' : 'bg-indigo-500 '" @click="goToNextWeek">
        <svg
          class="h-4 w-4 inline-block -mt-1" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
        </svg>
      </button>
      <button v-if="!onPhone" class="text-white px-4 py-2 rounded" :disabled="isLoading || saveNeeded" :class="isLoading || saveNeeded ? 'cursor-not-allowed bg-gray-300' : 'bg-indigo-500 '" @click="goToToday">
        Today
      </button>
      <button v-if="!onPhone" class="text-white px-4 py-2 rounded" :disabled="isLoading" :class="isLoading ? 'cursor-not-allowed bg-gray-300' : 'bg-green-500 '" @click="save">
        Save
      </button>
      <div class="flex w-full">
        <button
          class="w-full px-4 py-2 font-medium tracking-wide text-white capitalize transition-colors duration-200 transform rounded-md focus:outline-none"
          :class="isLoading || alreadyClocked ? 'cursor-not-allowed bg-gray-300' : clockedIn ? 'bg-red-500 hover:bg-red-400' : 'bg-yellow-500 hover:bg-yellow-400' "
          :disabled="isLoading || alreadyClocked"
          @click="clock()"
        >
          {{ clockedIn ? 'Clock out' : 'Clock In' }}
        </button>
      </div>
    </div>
    <div v-if="!onPhone" class="m-4">
      <div class="flex items-center">
        <h4 class="text-2xl font-semibold text-gray-700 mt-3">
          {{ 'Week Summary' }}
        </h4>
        <img v-if="isLoading" class="h-4 w-4 mb-1 ml-2 mt-5" src="../../public/black_oval.svg" alt="Loading icon">
      </div>

      <div class="my-6 overflow-hidden bg-white rounded-md shadow">
        <table class="w-full text-left border-collapse">
          <thead class="border-b">
            <tr>
              <th class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-indigo-700">
                Week
              </th>
              <th
                v-for="day in weekDays" :key="day.dateStr"
                class="px-5 py-3 text-sm font-medium text-gray-100 uppercase bg-indigo-700"
              >
                {{ day.dateStr }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr class="hover:bg-gray-200">
              <td class="px-6 py-4 text-lg text-gray-700 border-b whitespace-nowrap text-center">
                {{ 'Start time' }}
              </td>
              <td
                v-for="day in weekDays" :key="day.dateStr"
                class="px-6 py-4 text-lg text-gray-700 border-b"
              >
                <input
                  v-model="day.start"
                  :disabled="isAfter(day.date, startOfDay(new Date()))"
                  class="text-center w-full block mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
                  :class="isAfter(day.date, startOfDay(new Date())) ? 'cursor-not-allowed bg-gray-300' : ''"
                  type="time"
                  @change="saveNeeded = true"
                >
              </td>
            </tr>
            <tr class="hover:bg-gray-200">
              <td class="px-6 py-4 text-lg text-gray-700 border-b whitespace-nowrap text-center">
                {{ 'End time' }}
              </td>
              <td
                v-for="day in weekDays" :key="day.dateStr"
                class="px-6 py-4 text-lg text-gray-700 border-b"
              >
                <input
                  v-model="day.end"
                  type="time"
                  :disabled="isAfter(day.date, startOfDay(new Date()))"
                  class="text-center w-full block mt-1 border-gray-200 rounded-md focus:border-indigo-600 focus:ring focus:ring-opacity-40 focus:ring-indigo-500"
                  :class="isAfter(day.date, startOfDay(new Date())) ? 'cursor-not-allowed bg-gray-300' : ''"
                  @change="saveNeeded = true"
                >
              </td>
            </tr>
            <tr class="hover:bg-gray-200">
              <td class="px-6 py-4 text-lg text-gray-700 border-b text-center">
                {{ 'Total' }}
              </td>
              <td
                v-for="day in weekDays" :key="day.dateStr"
                class="px-6 py-4 text-lg text-gray-700 border-b text-center"
              >
                <span class="text-gray-700">{{ day.duration ? day.duration : '00:00' }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
