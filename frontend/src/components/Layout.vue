<template>
  <div class="layout-container">
    <!-- 左侧边栏 -->
    <aside class="sidebar" :class="{ collapsed: isCollapsed }">
      <!-- Logo -->
      <div class="sidebar-logo" @click="$router.push('/')">
        <div class="logo-icon">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
          </svg>
        </div>
        <span class="logo-text" v-show="!isCollapsed">FitPulse</span>
      </div>

      <!-- 导航菜单 -->
      <el-menu
        :default-active="activeMenu"
        router
        class="sidebar-menu"
        :collapse="isCollapsed"
      >
        <el-menu-item index="/">
          <el-icon><HomeFilled /></el-icon>
          <template #title>首页</template>
        </el-menu-item>
        <el-menu-item index="/health">
          <el-icon><Document /></el-icon>
          <template #title>健康档案</template>
        </el-menu-item>
        <el-menu-item index="/agents">
          <el-icon><Avatar /></el-icon>
          <template #title>智能体</template>
        </el-menu-item>
        <el-menu-item index="/knowledge">
          <el-icon><Reading /></el-icon>
          <template #title>知识库</template>
        </el-menu-item>
        <el-menu-item index="/profile">
          <el-icon><User /></el-icon>
          <template #title>个人设置</template>
        </el-menu-item>
      </el-menu>

      <!-- 底部折叠按钮 -->
      <div class="sidebar-footer">
        <div class="collapse-btn" @click="isCollapsed = !isCollapsed">
          <el-icon v-if="isCollapsed"><Expand /></el-icon>
          <el-icon v-else><Fold /></el-icon>
        </div>
      </div>
    </aside>

    <!-- 右侧主内容区 -->
    <div class="main-wrapper">
      <!-- 顶部栏 -->
      <header class="top-header">
        <div class="header-left">
          <h1 class="page-title">{{ pageTitle }}</h1>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand" trigger="click">
            <div class="user-dropdown">
              <el-avatar :size="38" class="user-avatar">
                {{ userStore.userInfo?.nickname?.charAt(0) || 'U' }}
              </el-avatar>
              <div class="user-info">
                <span class="user-name">{{ userStore.userInfo?.nickname || '用户' }}</span>
                <span class="user-role">健康会员</span>
              </div>
              <el-icon class="dropdown-icon"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>
                  个人设置
                </el-dropdown-item>
                <el-dropdown-item command="logout" divided>
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <!-- 页面内容 -->
      <main class="main-content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessageBox } from 'element-plus'
import { 
  HomeFilled, 
  Document, 
  ChatDotRound, 
  User, 
  SwitchButton, 
  ArrowDown,
  Expand,
  Fold,
  Avatar,
  Reading
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isCollapsed = ref(false)
const activeMenu = computed(() => route.path)

const pageTitle = computed(() => {
  const titles = {
    '/': '首页',
    '/health': '健康档案',
    '/agents': '智能体中心',
    '/knowledge': '知识库',
    '/profile': '个人设置'
  }
  // 智能体编辑页面特殊处理
  if (route.path.startsWith('/agents/')) {
    return '智能体编辑'
  }
  // 智能体聊天页面特殊处理
  if (route.path.startsWith('/agent/chat/')) {
    return 'AI 助手'
  }
  return titles[route.path] || 'FitPulse'
})

const handleCommand = async (command) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      userStore.logout()
      router.push('/login')
    } catch {
      // 取消退出
    }
  } else if (command === 'profile') {
    router.push('/profile')
  }
}
</script>

<style scoped lang="scss">
.layout-container {
  display: flex;
  min-height: 100vh;
  width: 100%;
  position: relative;
}

/* 左侧边栏 */
.sidebar {
  width: 240px;
  height: 100vh;
  background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
  display: flex;
  flex-direction: column;
  position: fixed;
  left: 0;
  top: 0;
  z-index: 100;
  transition: width 0.3s ease;
  
  &.collapsed {
    width: 72px;
    
    .sidebar-logo {
      padding: 20px 0;
      justify-content: center;
    }
    
    .logo-icon {
      margin-right: 0;
    }
  }
}

.sidebar-logo {
  display: flex;
  align-items: center;
  padding: 20px 24px;
  cursor: pointer;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  
  .logo-icon {
    width: 40px;
    height: 40px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 12px;
    flex-shrink: 0;
    
    svg {
      width: 22px;
      height: 22px;
      color: #fff;
    }
  }
  
  .logo-text {
    font-size: 20px;
    font-weight: 700;
    color: #fff;
    white-space: nowrap;
  }
}

.sidebar-menu {
  flex: 1;
  border-right: none;
  background: transparent;
  padding: 16px 0;
  
  &:not(.el-menu--collapse) {
    width: 100%;
  }
  
  :deep(.el-menu-item) {
    height: 50px;
    line-height: 50px;
    margin: 4px 12px;
    border-radius: 10px;
    color: rgba(255, 255, 255, 0.7);
    
    .el-icon {
      font-size: 20px;
      color: rgba(255, 255, 255, 0.7);
    }
    
    &:hover {
      background: rgba(255, 255, 255, 0.1);
      color: #fff;
      
      .el-icon {
        color: #fff;
      }
    }
    
    &.is-active {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #fff;
      
      .el-icon {
        color: #fff;
      }
    }
  }
  
  // 折叠状态下的样式
  &.el-menu--collapse {
    :deep(.el-menu-item) {
      margin: 4px 8px;
      padding: 0 !important;
      justify-content: center;
      
      .el-icon {
        margin-right: 0;
      }
    }
  }
}

.sidebar-footer {
  padding: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  
  .collapse-btn {
    width: 100%;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 8px;
    cursor: pointer;
    color: rgba(255, 255, 255, 0.6);
    transition: all 0.3s;
    
    &:hover {
      background: rgba(255, 255, 255, 0.1);
      color: #fff;
    }
    
    .el-icon {
      font-size: 20px;
    }
  }
}

/* 右侧主区域 */
.main-wrapper {
  flex: 1;
  margin-left: 240px;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: #f0f2f5;
  transition: margin-left 0.3s ease;
  width: calc(100% - 240px);
}

.sidebar.collapsed ~ .main-wrapper,
.sidebar.collapsed + .main-wrapper {
  margin-left: 72px;
  width: calc(100% - 72px);
}

/* 顶部栏 */
.top-header {
  height: 64px;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  position: sticky;
  top: 0;
  z-index: 50;
  flex-shrink: 0;
  
  .header-left {
    .page-title {
      font-size: 20px;
      font-weight: 600;
      color: #1a1a2e;
      margin: 0;
    }
  }
  
  .header-right {
    .user-dropdown {
      display: flex;
      align-items: center;
      cursor: pointer;
      padding: 6px 12px;
      border-radius: 10px;
      transition: all 0.3s;
      
      &:hover {
        background: #f5f7fa;
      }
      
      .user-avatar {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: #fff;
        font-weight: 600;
        font-size: 15px;
      }
      
      .user-info {
        margin-left: 10px;
        display: flex;
        flex-direction: column;
        
        .user-name {
          font-size: 14px;
          font-weight: 600;
          color: #1a1a2e;
          line-height: 1.3;
        }
        
        .user-role {
          font-size: 12px;
          color: #9ca3af;
          line-height: 1.3;
        }
      }
      
      .dropdown-icon {
        margin-left: 6px;
        color: #9ca3af;
        font-size: 12px;
      }
    }
  }
}

/* 主内容区 */
.main-content {
  flex: 1;
  padding: 24px 32px;
  overflow-y: auto;
  width: 100%;
  box-sizing: border-box;
}

/* 响应式适配 */
@media (max-width: 1024px) {
  .sidebar {
    width: 72px;
    
    .sidebar-logo {
      padding: 20px 0;
      justify-content: center;
      
      .logo-text {
        display: none;
      }
      
      .logo-icon {
        margin-right: 0;
      }
    }
    
    .sidebar-menu {
      :deep(.el-menu-item) {
        margin: 4px 8px;
        padding: 0 !important;
        justify-content: center;
        
        .el-icon {
          margin-right: 0;
        }
        
        span {
          display: none;
        }
      }
    }
  }
  
  .main-wrapper {
    margin-left: 72px;
    width: calc(100% - 72px);
  }
  
  .main-content {
    padding: 20px;
  }
}

@media (max-width: 768px) {
  .sidebar {
    transform: translateX(-100%);
  }
  
  .main-wrapper {
    margin-left: 0;
    width: 100%;
  }
  
  .top-header {
    padding: 0 16px;
    
    .user-info {
      display: none;
    }
  }
  
  .main-content {
    padding: 16px;
  }
}
</style>
