import type { RouteRecordRaw } from 'vue-router'
import { createRouter, createWebHistory } from 'vue-router'

import PersonalDashboard from './components/PersonalDashboard.vue'
import { isTokenValid } from './composables/auth'
import Dashboard from './views/Dashboard.vue'
import Login from './views/Login.vue'
import Profile from './views/Profile.vue'
import Register from './views/Register.vue'
import Team from './views/Team.vue'
import TimeManagement from './views/TimeManagement.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'Login',
    component: Login,
    meta: { layout: 'empty' },
  },
  {
    path: '/register',
    name: 'Register',
    component: Register,
    meta: { layout: 'empty' },
  },
  {
    path: '/personalDashboard:id',
    name: 'PersonalDashboard',
    component: PersonalDashboard,
    meta: { layout: 'empty' },

  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
  },
  {
    path: '/timemanagement',
    name: 'Timemanagement',
    component: TimeManagement,
  },
  {
    path: '/profile/:id',
    name: 'Profile',
    component: Profile,
  },
  {
    path: '/teams',
    name: 'Team',
    component: Team,
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to, from, next) => {
  const unprotectedRoutes = ['Login', 'Register'] // Routes qui ne nécessitent pas d'authentification
  if (!unprotectedRoutes.includes(to.name as string)) {
    // Vérifie si la route n'est pas dans les routes non protégées
    const isLoggedIn = isTokenValid()
    if (!isLoggedIn)
      next({ name: 'Login' }) // Redirige vers la page de connexion si l'utilisateur n'est pas connecté

    else
      next() // L'utilisateur est connecté, autorise l'accès à la route
  }
  else {
    next() // Route non protégée, autorise l'accès
  }
})

export default router
