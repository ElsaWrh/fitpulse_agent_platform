<template>
  <div class="agent-center" v-loading="loading">
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

    <!-- 筛选和排序工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <el-select 
          v-model="filterCategory" 
          placeholder="筛选类别" 
          clearable
          style="width: 160px"
        >
          <el-option label="全部类别" value="" />
          <el-option label="健康顾问" value="HEALTH_COACH" />
          <el-option label="营养顾问" value="NUTRITION_COACH" />
          <el-option label="睡眠顾问" value="SLEEP_COACH" />
          <el-option label="健身教练" value="FITNESS_COACH" />
          <el-option label="自定义" value="CUSTOM" />
        </el-select>
      </div>
      <div class="toolbar-right">
        <span class="sort-label">排序：</span>
        <el-radio-group v-model="sortBy" size="small">
          <el-radio-button label="latest">最新创建</el-radio-button>
          <el-radio-button label="name">名称</el-radio-button>
          <el-radio-button label="updated">最近更新</el-radio-button>
        </el-radio-group>
      </div>
    </div>

    <!-- 智能体卡片列表 -->
    <div class="agents-grid" v-if="displayedAgents.length > 0">
      <div 
        v-for="agent in displayedAgents" 
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
            <span class="agent-category">{{ agent.categoryLabel }}</span>
          </div>
        </div>
        
        <p class="agent-description">{{ agent.description }}</p>
        
        <div class="agent-tags" v-if="agent.tags && agent.tags.length > 0">
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
          <el-button size="small" @click.stop="editAgent(agent)">
            <el-icon><Edit /></el-icon>
            编辑
          </el-button>
          <el-button 
            type="danger" 
            size="small" 
            plain
            @click.stop="confirmDelete(agent)"
          >
            <el-icon><Delete /></el-icon>
            删除
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
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, ChatDotRound, Edit, Delete } from '@element-plus/icons-vue'
import { getAgents, deleteAgent } from '@/api/agent'

const router = useRouter()
const agents = ref([])
const loading = ref(false)
const filterCategory = ref('')
const sortBy = ref('latest')

// 辅助函数 - 获取类别标签
const getCategoryLabel = (category) => {
  const labels = {
    'HEALTH_COACH': '健康顾问',
    'NUTRITION_COACH': '营养顾问',
    'SLEEP_COACH': '睡眠顾问',
    'FITNESS_COACH': '健身教练',
    'CUSTOM': '自定义'
  }
  return labels[category] || category
}

// 辅助函数 - 获取图标颜色
const getIconColor = (category) => {
  const colors = {
    'HEALTH_COACH': 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    'NUTRITION_COACH': 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    'SLEEP_COACH': 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    'FITNESS_COACH': 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)'
  }
  return colors[category] || 'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)'
}

// 辅助函数 - 生成标签
const generateTags = (category) => {
  const tags = {
    'HEALTH_COACH': ['综合健康', '健身计划', '生活方式'],
    'NUTRITION_COACH': ['饮食', '营养', '减脂搭配'],
    'SLEEP_COACH': ['睡眠', '作息', '恢复'],
    'FITNESS_COACH': ['健身', '训练', '增肌']
  }
  return tags[category] || ['智能体']
}

/**
 * 加载智能体列表
 */
const loadAgents = async () => {
  loading.value = true
  try {
    const data = await getAgents()
    agents.value = data.map(agent => ({
      ...agent,
      icon: agent.avatarUrl || '🤖',
      iconColor: getIconColor(agent.category),
      categoryLabel: getCategoryLabel(agent.category),
      tags: generateTags(agent.category),
      description: agent.description || '暂无描述'
    }))
  } catch (error) {
    ElMessage.error('加载智能体列表失败: ' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

/**
 * 筛选和排序后的智能体列表
 */
const displayedAgents = computed(() => {
  let filtered = agents.value

  // 筛选类别
  if (filterCategory.value) {
    filtered = filtered.filter(agent => agent.category === filterCategory.value)
  }

  // 排序
  const sorted = [...filtered]
  switch (sortBy.value) {
    case 'latest':
      sorted.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
      break
    case 'name':
      sorted.sort((a, b) => a.name.localeCompare(b.name, 'zh-CN'))
      break
    case 'updated':
      sorted.sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt))
      break
  }

  return sorted
})

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

/**
 * 确认删除智能体
 */
const confirmDelete = async (agent) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除智能体"${agent.name}"吗？删除后将无法恢复。`,
      '确认删除',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )
    
    await handleDelete(agent)
  } catch (error) {
    // 用户取消删除
    if (error !== 'cancel') {
      console.error('删除确认失败:', error)
    }
  }
}

/**
 * 删除智能体
 */
const handleDelete = async (agent) => {
  loading.value = true
  try {
    await deleteAgent(agent.id)
    ElMessage.success('删除成功')
    await loadAgents()
  } catch (error) {
    ElMessage.error('删除失败: ' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadAgents()
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
  margin-bottom: 24px;
  
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

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: #fff;
  border-radius: 8px;
  margin-bottom: 24px;
  border: 1px solid #e4e7ed;
  
  .toolbar-left {
    display: flex;
    gap: 12px;
    align-items: center;
  }
  
  .toolbar-right {
    display: flex;
    gap: 12px;
    align-items: center;
    
    .sort-label {
      font-size: 14px;
      color: #606266;
      font-weight: 500;
    }
  }
  
  @media (max-width: 768px) {
    flex-direction: column;
    gap: 12px;
    
    .toolbar-left,
    .toolbar-right {
      width: 100%;
      justify-content: space-between;
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
    
    .el-button {
      flex: 1;
      
      &:last-child {
        flex: 0 0 auto;
      }
    }
  }
}
</style>
