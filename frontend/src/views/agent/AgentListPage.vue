<template>
  <div class="agent-center">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h1 class="page-title">智能体中心</h1>
        <p class="page-subtitle">管理和使用你的健康智能体</p>
      </div>
      <div class="header-right">
        <el-button type="primary" :icon="Plus" @click="createNewAgent">
          创建智能体
        </el-button>
      </div>
    </div>

    <!-- 智能体卡片列表 -->
    <div class="agents-grid" v-if="agents.length > 0">
      <div 
        v-for="agent in agents" 
        :key="agent.id"
        class="agent-card"
        @click="handleAgentClick(agent)"
      >
        <div class="card-header">
          <div class="agent-icon" :style="{ background: agent.iconColor }">
            {{ agent.icon }}
          </div>
          <div class="agent-meta">
            <h3 class="agent-name">{{ agent.name }}</h3>
            <span class="agent-category">{{ agent.category }}</span>
          </div>
        </div>
        
        <p class="agent-description">{{ agent.description }}</p>
        
        <div class="agent-tags">
          <el-tag 
            v-for="tag in agent.tags" 
            :key="tag"
            size="small"
            type="info"
            effect="plain"
          >
            {{ tag }}
          </el-tag>
        </div>
        
        <div class="card-footer">
          <el-button type="primary" size="small" @click.stop="startChat(agent)">
            <el-icon><ChatDotRound /></el-icon>
            开始对话
          </el-button>
          <el-button 
            v-if="!agent.isSystem" 
            size="small" 
            @click.stop="editAgent(agent)"
          >
            <el-icon><Edit /></el-icon>
            编辑
          </el-button>
        </div>
      </div>
    </div>

    <!-- 空状态 -->
    <el-empty 
      v-else 
      description="暂无智能体"
      :image-size="200"
    >
      <el-button type="primary" @click="createNewAgent">创建第一个智能体</el-button>
    </el-empty>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus, ChatDotRound, Edit } from '@element-plus/icons-vue'

const router = useRouter()

// 预置智能体数据(后续从后端API获取)
const agents = ref([
  {
    id: 'health_assistant',
    name: 'AI 健康助手',
    description: '综合健康咨询,帮你制定运动和生活方式计划',
    icon: '🏃',
    iconColor: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    category: '系统预置',
    tags: ['综合健康', '健身计划', '生活方式'],
    isSystem: true
  },
  {
    id: 'diet_assistant',
    name: '饮食营养顾问',
    description: '分析饮食结构,给出科学饮食和营养建议',
    icon: '🍎',
    iconColor: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    category: '系统预置',
    tags: ['饮食', '营养', '减脂搭配'],
    isSystem: true
  },
  {
    id: 'sleep_assistant',
    name: '睡眠改善顾问',
    description: '帮助你优化作息,提高睡眠质量与恢复效率',
    icon: '🌙',
    iconColor: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    category: '系统预置',
    tags: ['睡眠', '作息', '恢复'],
    isSystem: true
  }
])

/**
 * 点击智能体卡片
 */
const handleAgentClick = (agent) => {
  startChat(agent)
}

/**
 * 开始对话
 */
const startChat = (agent) => {
  router.push(`/agent/chat/${agent.id}`)
}

/**
 * 编辑智能体
 */
const editAgent = (agent) => {
  router.push(`/agents/${agent.id}`)
}

/**
 * 创建新智能体
 */
const createNewAgent = () => {
  router.push('/agents/new')
}

onMounted(() => {
  // TODO: 从后端加载智能体列表
  // loadAgents()
})
</script>

<style scoped lang="scss">
.agent-center {
  padding: 24px;
  width: 100%;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
  
  .header-left {
    .page-title {
      font-size: 28px;
      font-weight: 600;
      color: #1a1a1a;
      margin: 0 0 8px;
    }
    
    .page-subtitle {
      font-size: 14px;
      color: #909399;
      margin: 0;
    }
  }
}

.agents-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 24px;
  
  @media (max-width: 1200px) {
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  }
  
  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.agent-card {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  border: 1px solid #e4e7ed;
  transition: all 0.3s ease;
  cursor: pointer;
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 24px rgba(0, 0, 0, 0.1);
    border-color: #667eea;
  }
  
  .card-header {
    display: flex;
    align-items: flex-start;
    gap: 16px;
    margin-bottom: 16px;
    
    .agent-icon {
      width: 56px;
      height: 56px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 32px;
      flex-shrink: 0;
    }
    
    .agent-meta {
      flex: 1;
      min-width: 0;
      
      .agent-name {
        font-size: 18px;
        font-weight: 600;
        color: #1a1a1a;
        margin: 0 0 4px;
      }
      
      .agent-category {
        font-size: 12px;
        color: #909399;
      }
    }
  }
  
  .agent-description {
    font-size: 14px;
    line-height: 1.6;
    color: #606266;
    margin: 0 0 16px;
    min-height: 44px;
  }
  
  .agent-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 16px;
    min-height: 32px;
    
    .el-tag {
      border-radius: 4px;
    }
  }
  
  .card-footer {
    display: flex;
    gap: 8px;
    padding-top: 16px;
    border-top: 1px solid #f0f0f0;
  }
}
</style>
