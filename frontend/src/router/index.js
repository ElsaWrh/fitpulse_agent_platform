import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'
import Layout from '@/components/Layout.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { requiresAuth: false }
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('@/views/RegisterView.vue'),
      meta: { requiresAuth: false }
    },
    {
      path: '/',
      component: Layout,
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'home',
          component: () => import('@/views/HomeView.vue')
        },
        {
          path: 'profile',
          name: 'profile',
          component: () => import('@/views/ProfileView.vue')
        },
        {
          path: 'health',
          name: 'health',
          component: () => import('@/views/HealthView.vue')
        },
        {
          path: 'chat',
          name: 'chat',
          component: () => import('@/views/ChatView.vue')
        },
        {
          path: 'agents',
          name: 'agents',
          component: () => import('@/views/agent/AgentListPage.vue')
        },
        {
          path: 'agents/:id',
          name: 'agent-edit',
          component: () => import('@/views/agent/AgentEditPage.vue')
        },
        {
          path: 'agent/chat/:agentId',
          name: 'agent-chat',
          component: () => import('@/views/agent/AgentChatPage.vue')
        },
        {
          path: 'knowledge',
          name: 'knowledge',
          component: () => import('@/views/kb/KnowledgePage.vue')
        }
      ]
    }
  ]
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  
  // 需要登录的页面
  if (to.meta.requiresAuth) {
    if (!userStore.token) {
      next('/login')
      return
    }
  }
  
  // 已登录用户访问登录/注册页面，跳转到首页
  if ((to.path === '/login' || to.path === '/register') && userStore.token) {
    next('/')
    return
  }
  
  next()
})

export default router
