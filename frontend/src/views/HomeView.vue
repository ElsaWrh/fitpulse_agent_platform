<template>
  <div class="home-view">
    <!-- 欢迎横幅 -->
    <div class="welcome-banner">
      <div class="welcome-content">
        <div class="welcome-text">
          <h1>
            <span class="greeting">{{ greeting }}，</span>
            <span class="username">{{ userStore.userInfo?.nickname || '用户' }}</span>
          </h1>
          <p class="welcome-subtitle">今天是开启健康生活的好日子，让我们一起努力！</p>
        </div>
        <div class="welcome-illustration">
          <svg viewBox="0 0 200 160" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="100" cy="80" r="60" fill="rgba(255,255,255,0.2)"/>
            <path d="M100 40 L100 120 M60 80 L140 80" stroke="white" stroke-width="4" stroke-linecap="round"/>
            <circle cx="100" cy="80" r="40" stroke="white" stroke-width="3" fill="none"/>
            <path d="M80 70 Q100 50 120 70 Q100 100 80 70" fill="white" opacity="0.8"/>
          </svg>
        </div>
      </div>
    </div>

    <!-- 快速统计 -->
    <div class="stats-section">
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
            <el-icon :size="28"><Calendar /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ healthDays }}</span>
            <span class="stat-label">健康记录天数</span>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
            <el-icon :size="28"><TrendCharts /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ workoutCount }}</span>
            <span class="stat-label">运动记录次数</span>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
            <el-icon :size="28"><Timer /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ totalMinutes }}</span>
            <span class="stat-label">累计运动分钟</span>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);">
            <el-icon :size="28"><Aim /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ goalProgress }}%</span>
            <span class="stat-label">目标完成度</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 功能卡片 -->
    <div class="features-section">
      <h2 class="section-title">
        <span class="title-icon">🚀</span>
        快速开始
      </h2>
      
      <div class="features-grid">
        <div class="feature-card" @click="$router.push('/profile')">
          <div class="feature-icon">
            <el-icon :size="36"><User /></el-icon>
          </div>
          <div class="feature-content">
            <h3>个人资料</h3>
            <p>管理您的基础信息与健康目标设定</p>
          </div>
          <div class="feature-arrow">
            <el-icon><ArrowRight /></el-icon>
          </div>
        </div>
        
        <div class="feature-card" @click="$router.push('/health')">
          <div class="feature-icon health">
            <el-icon :size="36"><Document /></el-icon>
          </div>
          <div class="feature-content">
            <h3>健康档案</h3>
            <p>记录体重、运动等健康数据变化</p>
          </div>
          <div class="feature-arrow">
            <el-icon><ArrowRight /></el-icon>
          </div>
        </div>
        
        <div class="feature-card" @click="$router.push('/agents')">
          <div class="feature-icon chat">
            <el-icon :size="36"><ChatDotRound /></el-icon>
          </div>
          <div class="feature-content">
            <h3>智能体助手</h3>
            <p>获取智能化的健康建议与运动方案</p>
          </div>
          <div class="feature-arrow">
            <el-icon><ArrowRight /></el-icon>
          </div>
        </div>
      </div>
    </div>

    <!-- 健康提示 -->
    <div class="tips-section">
      <h2 class="section-title">
        <span class="title-icon">💡</span>
        今日健康提示
      </h2>
      
      <div class="tips-grid">
        <div class="tip-card">
          <div class="tip-emoji">💧</div>
          <div class="tip-content">
            <h4>多喝水</h4>
            <p>建议每天饮用 8 杯水，保持身体水分平衡</p>
          </div>
        </div>
        
        <div class="tip-card">
          <div class="tip-emoji">🏃</div>
          <div class="tip-content">
            <h4>适量运动</h4>
            <p>每周至少 150 分钟中等强度有氧运动</p>
          </div>
        </div>
        
        <div class="tip-card">
          <div class="tip-emoji">😴</div>
          <div class="tip-content">
            <h4>充足睡眠</h4>
            <p>成年人每天需要 7-9 小时的优质睡眠</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { 
  User, 
  Document, 
  TrendCharts, 
  ChatDotRound, 
  Calendar,
  Timer,
  Aim,
  ArrowRight 
} from '@element-plus/icons-vue'

const userStore = useUserStore()

// 模拟数据（后续可从API获取）
const healthDays = ref(15)
const workoutCount = ref(23)
const totalMinutes = ref(680)
const goalProgress = ref(72)

const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 6) return '夜深了'
  if (hour < 12) return '早上好'
  if (hour < 14) return '中午好'
  if (hour < 18) return '下午好'
  return '晚上好'
})

onMounted(async () => {
  if (!userStore.userInfo) {
    await userStore.getUserInfo()
  }
})
</script>

<style scoped lang="scss">
.home-view {
  width: 100%;
  min-height: 100%;
}

/* 欢迎横幅 */
.welcome-banner {
  width: 100%;
  box-sizing: border-box;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px;
  padding: 40px 48px;
  margin-bottom: 32px;
  position: relative;
  overflow: hidden;
  
  &::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -10%;
    width: 400px;
    height: 400px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 50%;
  }
  
  .welcome-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: relative;
    z-index: 1;
  }
  
  .welcome-text {
    h1 {
      font-size: 32px;
      color: #fff;
      margin: 0 0 12px;
      font-weight: 600;
      
      .greeting {
        opacity: 0.9;
      }
      
      .username {
        font-weight: 700;
      }
    }
    
    .welcome-subtitle {
      font-size: 16px;
      color: rgba(255, 255, 255, 0.85);
      margin: 0;
    }
  }
  
  .welcome-illustration {
    svg {
      width: 140px;
      height: 120px;
    }
  }
}

/* 统计数据 */
.stats-section {
  width: 100%;
  box-sizing: border-box;
  margin-bottom: 40px;
  
  .stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
  }
  
  .stat-card {
    background: #fff;
    border-radius: 16px;
    padding: 24px;
    display: flex;
    align-items: center;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    transition: all 0.3s;
    
    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
    }
    
    .stat-icon {
      width: 60px;
      height: 60px;
      border-radius: 16px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      margin-right: 20px;
      flex-shrink: 0;
    }
    
    .stat-info {
      display: flex;
      flex-direction: column;
      
      .stat-value {
        font-size: 28px;
        font-weight: 700;
        color: #1a1a2e;
        line-height: 1.2;
      }
      
      .stat-label {
        font-size: 14px;
        color: #9ca3af;
        margin-top: 4px;
      }
    }
  }
}

/* 功能卡片 */
.features-section {
  width: 100%;
  box-sizing: border-box;
  margin-bottom: 40px;
  
  .section-title {
    font-size: 20px;
    font-weight: 600;
    color: #1a1a2e;
    margin: 0 0 24px;
    display: flex;
    align-items: center;
    
    .title-icon {
      margin-right: 10px;
      font-size: 24px;
    }
  }
  
  .features-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 24px;
  }
  
  .feature-card {
    background: #fff;
    border-radius: 16px;
    padding: 28px;
    display: flex;
    align-items: center;
    cursor: pointer;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    transition: all 0.3s;
    
    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
      
      .feature-arrow {
        opacity: 1;
        transform: translateX(0);
      }
    }
    
    .feature-icon {
      width: 72px;
      height: 72px;
      border-radius: 16px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      margin-right: 20px;
      flex-shrink: 0;
      
      &.health {
        background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
      }
      
      &.chat {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
      }
    }
    
    .feature-content {
      flex: 1;
      
      h3 {
        font-size: 18px;
        font-weight: 600;
        color: #1a1a2e;
        margin: 0 0 8px;
      }
      
      p {
        font-size: 14px;
        color: #6b7280;
        margin: 0;
        line-height: 1.5;
      }
    }
    
    .feature-arrow {
      color: #9ca3af;
      opacity: 0;
      transform: translateX(-10px);
      transition: all 0.3s;
    }
  }
}

/* 健康提示 */
.tips-section {
  width: 100%;
  box-sizing: border-box;
  
  .section-title {
    font-size: 20px;
    font-weight: 600;
    color: #1a1a2e;
    margin: 0 0 24px;
    display: flex;
    align-items: center;
    
    .title-icon {
      margin-right: 10px;
      font-size: 24px;
    }
  }
  
  .tips-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 24px;
  }
  
  .tip-card {
    background: #fff;
    border-radius: 16px;
    padding: 24px;
    display: flex;
    align-items: flex-start;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
    
    .tip-emoji {
      font-size: 36px;
      margin-right: 16px;
      line-height: 1;
    }
    
    .tip-content {
      h4 {
        font-size: 16px;
        font-weight: 600;
        color: #1a1a2e;
        margin: 0 0 8px;
      }
      
      p {
        font-size: 14px;
        color: #6b7280;
        margin: 0;
        line-height: 1.6;
      }
    }
  }
}

/* 响应式适配 */
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr) !important;
  }
  
  .features-grid,
  .tips-grid {
    grid-template-columns: repeat(2, 1fr) !important;
  }
}

@media (max-width: 768px) {
  .welcome-banner {
    padding: 28px;
    
    .welcome-text h1 {
      font-size: 24px;
    }
    
    .welcome-illustration {
      display: none;
    }
  }
  
  .stats-grid,
  .features-grid,
  .tips-grid {
    grid-template-columns: 1fr !important;
  }
}
</style>
