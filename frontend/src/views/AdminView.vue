<template>
  <div class="admin-container">
    <!-- 头部统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card class="stat-card">
          <el-statistic title="总用户数" :value="stats.totalUsers">
            <template #prefix>
              <el-icon><User /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <el-statistic title="智能体数量" :value="stats.totalAgents">
            <template #prefix>
              <el-icon><Avatar /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <el-statistic title="知识库数量" :value="stats.totalKnowledge">
            <template #prefix>
              <el-icon><Reading /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <el-statistic title="今日活跃" :value="stats.activeToday">
            <template #prefix>
              <el-icon><TrendCharts /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
    </el-row>

    <!-- 标签页 -->
    <el-card class="tab-card">
      <el-tabs v-model="activeTab">
        <!-- 用户管理标签 -->
        <el-tab-pane label="用户管理" name="users" v-if="userStore.hasPermission('user:list')">
          <div class="tab-toolbar">
            <el-button type="primary" @click="showCreateUserDialog" v-if="userStore.hasPermission('user:create')">
              <el-icon><Plus /></el-icon>
              创建用户
            </el-button>
            <el-input
              v-model="userSearch"
              placeholder="搜索用户（邮箱/昵称）"
              style="width: 300px; margin-left: 10px"
              clearable
              @change="loadUsers"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>

          <el-table :data="users" style="width: 100%; margin-top: 20px" stripe v-loading="usersLoading">
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="email" label="邮箱" width="220" />
            <el-table-column prop="nickname" label="昵称" width="150" />
            <el-table-column label="角色" width="120">
              <template #default="{ row }">
                <el-tag :type="getRoleTagType(row)">
                  {{ getRoleName(row) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.deleted === 1 ? 'info' : (row.status === 'ACTIVE' ? 'success' : 'warning')">
                  {{ row.deleted === 1 ? '已删除' : (row.status === 'ACTIVE' ? '正常' : '禁用') }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createdAt" label="创建时间" width="180">
              <template #default="{ row }">
                {{ formatDate(row.createdAt) }}
              </template>
            </el-table-column>
            <el-table-column label="操作" fixed="right" width="280">
              <template #default="{ row }">
                <el-button type="primary" size="small" @click="viewUser(row)" link>查看</el-button>
                <el-button 
                  type="warning" 
                  size="small" 
                  @click="showEditUserDialog(row)"
                  link
                  v-if="userStore.hasPermission('user:edit') && row.id !== userStore.user?.id"
                >
                  编辑
                </el-button>
                <el-button 
                  v-if="row.deleted === 0"
                  type="danger" 
                  size="small" 
                  @click="handleDeleteUser(row)"
                  link
                  :disabled="row.id === userStore.user?.id"
                >
                  删除
                </el-button>
                <el-button 
                  v-else
                  type="success" 
                  size="small" 
                  @click="handleRestoreUser(row)"
                  link
                >
                  恢复
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <el-pagination
            v-if="userTotal > userPageSize"
            v-model:current-page="userCurrentPage"
            v-model:page-size="userPageSize"
            :total="userTotal"
            layout="total, sizes, prev, pager, next, jumper"
            :page-sizes="[10, 20, 50, 100]"
            @current-change="loadUsers"
            @size-change="loadUsers"
            style="margin-top: 20px; justify-content: center"
          />
        </el-tab-pane>

        <!-- 智能体管理标签 -->
        <el-tab-pane label="智能体管理" name="agents" v-if="userStore.hasPermission('agent:view')">
          <div class="tab-toolbar">
            <el-button type="primary" @click="$router.push('/agents')">
              <el-icon><Plus /></el-icon>
              创建智能体
            </el-button>
            <el-input
              v-model="agentSearch"
              placeholder="搜索智能体"
              style="width: 300px; margin-left: 10px"
              clearable
              @change="loadAgents"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </div>

          <el-table :data="agents" style="width: 100%; margin-top: 20px" stripe v-loading="agentsLoading">
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="name" label="名称" width="200" />
            <el-table-column prop="description" label="描述" show-overflow-tooltip />
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'info'">
                  {{ row.status === 'ACTIVE' ? '启用' : '禁用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createdAt" label="创建时间" width="180">
              <template #default="{ row }">
                {{ formatDate(row.createdAt) }}
              </template>
            </el-table-column>
            <el-table-column label="操作" fixed="right" width="200">
              <template #default="{ row }">
                <el-button type="primary" size="small" @click="$router.push(`/agents/${row.id}`)" link>
                  编辑
                </el-button>
                <el-button 
                  type="danger" 
                  size="small" 
                  @click="handleDeleteAgent(row)"
                  link
                  v-if="userStore.hasPermission('agent:delete')"
                >
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <el-pagination
            v-if="agentTotal > agentPageSize"
            v-model:current-page="agentCurrentPage"
            v-model:page-size="agentPageSize"
            :total="agentTotal"
            layout="total, sizes, prev, pager, next"
            :page-sizes="[10, 20, 50]"
            @current-change="loadAgents"
            @size-change="loadAgents"
            style="margin-top: 20px; justify-content: center"
          />
        </el-tab-pane>

        <!-- 知识库管理标签 -->
        <el-tab-pane label="知识库管理" name="knowledge" v-if="userStore.hasPermission('knowledge:edit')">
          <div class="tab-toolbar">
            <el-button type="primary" @click="showCreateKnowledgeDialog">
              <el-icon><Plus /></el-icon>
              创建知识库
            </el-button>
          </div>

          <el-table :data="knowledgeList" style="width: 100%; margin-top: 20px" stripe v-loading="knowledgeLoading">
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="title" label="标题" width="250" />
            <el-table-column prop="content" label="内容" show-overflow-tooltip />
            <el-table-column prop="category" label="分类" width="120" />
            <el-table-column prop="createdAt" label="创建时间" width="180">
              <template #default="{ row }">
                {{ formatDate(row.createdAt) }}
              </template>
            </el-table-column>
            <el-table-column label="操作" fixed="right" width="150">
              <template #default="{ row }">
                <el-button type="primary" size="small" @click="showEditKnowledgeDialog(row)" link>
                  编辑
                </el-button>
                <el-button type="danger" size="small" @click="handleDeleteKnowledge(row)" link>
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <el-pagination
            v-if="knowledgeTotal > knowledgePageSize"
            v-model:current-page="knowledgeCurrentPage"
            v-model:page-size="knowledgePageSize"
            :total="knowledgeTotal"
            layout="total, prev, pager, next"
            @current-change="loadKnowledge"
            style="margin-top: 20px; justify-content: center"
          />
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <!-- 创建/编辑用户对话框 -->
    <el-dialog 
      v-model="userDialogVisible" 
      :title="userDialogMode === 'create' ? '创建用户' : '编辑用户'" 
      width="500px"
    >
      <el-form :model="userForm" :rules="userFormRules" ref="userFormRef" label-width="100px">
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email" :disabled="userDialogMode === 'edit'" />
        </el-form-item>
        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="userForm.nickname" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="userDialogMode === 'create'">
          <el-input v-model="userForm.password" type="password" show-password />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="userForm.phone" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="userForm.role" style="width: 100%">
            <el-option label="普通用户" value="ROLE_USER" />
            <el-option label="系统管理员" value="ROLE_ADMIN" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="userForm.status" style="width: 100%">
            <el-option label="正常" value="ACTIVE" />
            <el-option label="禁用" value="DISABLED" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="userDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveUser" :loading="userSaving">保存</el-button>
      </template>
    </el-dialog>

    <!-- 创建/编辑知识库对话框 -->
    <el-dialog 
      v-model="knowledgeDialogVisible" 
      :title="knowledgeDialogMode === 'create' ? '创建知识库' : '编辑知识库'" 
      width="600px"
    >
      <el-form :model="knowledgeForm" ref="knowledgeFormRef" label-width="100px">
        <el-form-item label="标题" required>
          <el-input v-model="knowledgeForm.title" />
        </el-form-item>
        <el-form-item label="分类">
          <el-input v-model="knowledgeForm.category" />
        </el-form-item>
        <el-form-item label="内容" required>
          <el-input 
            v-model="knowledgeForm.content" 
            type="textarea" 
            :rows="10"
            placeholder="请输入知识库内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="knowledgeDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveKnowledge" :loading="knowledgeSaving">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Setting, User, Avatar, Reading, TrendCharts, Plus, Search 
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { 
  getUserListAPI, 
  createUserAPI, 
  updateUserAPI, 
  deleteUserAPI, 
  restoreUserAPI,
  getAllAgentsAPI,
  deleteAgentAPI,
  getAllKnowledgeAPI,
  createKnowledgeAPI,
  updateKnowledgeAPI,
  deleteKnowledgeAPI,
  getSystemStatsAPI
} from '@/api/admin'

const userStore = useUserStore()

// 标签页
const activeTab = ref('users')

// 统计数据
const stats = reactive({
  totalUsers: 0,
  totalAgents: 0,
  totalKnowledge: 0,
  activeToday: 0
})

// ==================== 用户管理 ====================
const users = ref([])
const userCurrentPage = ref(1)
const userPageSize = ref(10)
const userTotal = ref(0)
const usersLoading = ref(false)
const userSearch = ref('')

const userDialogVisible = ref(false)
const userDialogMode = ref('create') // 'create' | 'edit'
const userFormRef = ref(null)
const userSaving = ref(false)
const userForm = reactive({
  id: null,
  email: '',
  nickname: '',
  password: '',
  phone: '',
  role: 'ROLE_USER',
  status: 'ACTIVE'
})

const userFormRules = {
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 8, message: '密码至少8位', trigger: 'blur' }
  ]
}

// 加载用户列表
const loadUsers = async () => {
  usersLoading.value = true
  try {
    // TODO: 替换为实际API调用
    // const res = await getUserListAPI({
    //   page: userCurrentPage.value,
    //   size: userPageSize.value,
    //   search: userSearch.value
    // })
    // users.value = res.data.records
    // userTotal.value = res.data.total
    
    // 模拟数据
    users.value = [
      {
        id: 1,
        email: '13811899957@163.com',
        nickname: 'elsa',
        role: 'ROLE_USER',
        status: 'ACTIVE',
        deleted: 0,
        createdAt: '2024-01-01T10:00:00'
      },
      {
        id: 4,
        email: 'admin@fitpulse.com',
        nickname: '系统管理员',
        role: 'ROLE_ADMIN',
        status: 'ACTIVE',
        deleted: 0,
        createdAt: '2024-01-08T15:30:00'
      }
    ]
    userTotal.value = users.value.length
    stats.totalUsers = users.value.filter(u => u.deleted === 0).length
  } catch (error) {
    ElMessage.error('加载用户列表失败：' + error.message)
  } finally {
    usersLoading.value = false
  }
}

// 显示创建用户对话框
const showCreateUserDialog = () => {
  userDialogMode.value = 'create'
  Object.assign(userForm, {
    id: null,
    email: '',
    nickname: '',
    password: '',
    phone: '',
    role: 'ROLE_USER',
    status: 'ACTIVE'
  })
  userDialogVisible.value = true
}

// 显示编辑用户对话框
const showEditUserDialog = (user) => {
  userDialogMode.value = 'edit'
  Object.assign(userForm, {
    id: user.id,
    email: user.email,
    nickname: user.nickname,
    password: '',
    phone: user.phone || '',
    role: user.role || 'ROLE_USER',
    status: user.status
  })
  userDialogVisible.value = true
}

// 保存用户
const handleSaveUser = async () => {
  if (!userFormRef.value) return
  
  try {
    await userFormRef.value.validate()
    userSaving.value = true
    
    if (userDialogMode.value === 'create') {
      // await createUserAPI(userForm)
      ElMessage.success('用户创建成功')
    } else {
      // await updateUserAPI(userForm.id, userForm)
      ElMessage.success('用户更新成功')
    }
    
    userDialogVisible.value = false
    loadUsers()
  } catch (error) {
    if (error !== false) {
      ElMessage.error('保存失败：' + error.message)
    }
  } finally {
    userSaving.value = false
  }
}

// 查看用户详情
const viewUser = (user) => {
  const roleNames = user.roles?.map(r => r.role_name).join(', ') || getRoleName(user)
  ElMessageBox.alert(
    `<div style="text-align: left;">
      <p><strong>ID:</strong> ${user.id}</p>
      <p><strong>邮箱:</strong> ${user.email}</p>
      <p><strong>昵称:</strong> ${user.nickname}</p>
      <p><strong>角色:</strong> ${roleNames}</p>
      <p><strong>状态:</strong> ${user.deleted === 1 ? '已删除' : (user.status === 'ACTIVE' ? '正常' : '禁用')}</p>
      <p><strong>手机号:</strong> ${user.phone || '-'}</p>
      <p><strong>创建时间:</strong> ${formatDate(user.createdAt)}</p>
    </div>`,
    '用户详情',
    {
      dangerouslyUseHTMLString: true,
      confirmButtonText: '关闭'
    }
  )
}

// 软删除用户
const handleDeleteUser = async (user) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除用户 "${user.nickname}" (${user.email}) 吗？删除后可以恢复。`,
      '删除确认',
      {
        type: 'warning',
        confirmButtonText: '确认删除',
        cancelButtonText: '取消'
      }
    )
    
    // await deleteUserAPI(user.id)
    ElMessage.success('用户已删除（软删除）')
    loadUsers()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败：' + error.message)
    }
  }
}

// 恢复用户
const handleRestoreUser = async (user) => {
  try {
    await ElMessageBox.confirm(
      `确定要恢复用户 "${user.nickname}" (${user.email}) 吗？`,
      '恢复确认',
      {
        type: 'success',
        confirmButtonText: '确认恢复',
        cancelButtonText: '取消'
      }
    )
    
    // await restoreUserAPI(user.id)
    ElMessage.success('用户已恢复')
    loadUsers()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('恢复失败：' + error.message)
    }
  }
}

// ==================== 智能体管理 ====================
const agents = ref([])
const agentCurrentPage = ref(1)
const agentPageSize = ref(10)
const agentTotal = ref(0)
const agentsLoading = ref(false)
const agentSearch = ref('')

// 加载智能体列表
const loadAgents = async () => {
  agentsLoading.value = true
  try {
    // TODO: 替换为实际API调用
    // const res = await getAllAgentsAPI({
    //   page: agentCurrentPage.value,
    //   size: agentPageSize.value,
    //   search: agentSearch.value
    // })
    // agents.value = res.data.records
    // agentTotal.value = res.data.total
    
    // 模拟数据
    agents.value = [
      {
        id: 1,
        name: '健康顾问',
        description: '专业的健康咨询智能体',
        status: 'ACTIVE',
        createdAt: '2024-01-05T10:00:00'
      }
    ]
    agentTotal.value = agents.value.length
    stats.totalAgents = agents.value.length
  } catch (error) {
    ElMessage.error('加载智能体列表失败：' + error.message)
  } finally {
    agentsLoading.value = false
  }
}

// 删除智能体
const handleDeleteAgent = async (agent) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除智能体 "${agent.name}" 吗？此操作不可恢复！`,
      '删除确认',
      {
        type: 'warning',
        confirmButtonText: '确认删除',
        cancelButtonText: '取消'
      }
    )
    
    // await deleteAgentAPI(agent.id)
    ElMessage.success('智能体已删除')
    loadAgents()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败：' + error.message)
    }
  }
}

// ==================== 知识库管理 ====================
const knowledgeList = ref([])
const knowledgeCurrentPage = ref(1)
const knowledgePageSize = ref(10)
const knowledgeTotal = ref(0)
const knowledgeLoading = ref(false)

const knowledgeDialogVisible = ref(false)
const knowledgeDialogMode = ref('create')
const knowledgeFormRef = ref(null)
const knowledgeSaving = ref(false)
const knowledgeForm = reactive({
  id: null,
  title: '',
  content: '',
  category: ''
})

// 加载知识库列表
const loadKnowledge = async () => {
  knowledgeLoading.value = true
  try {
    // TODO: 替换为实际API调用
    // const res = await getAllKnowledgeAPI({
    //   page: knowledgeCurrentPage.value,
    //   size: knowledgePageSize.value
    // })
    // knowledgeList.value = res.data.records
    // knowledgeTotal.value = res.data.total
    
    // 模拟数据
    knowledgeList.value = [
      {
        id: 1,
        title: '健康饮食指南',
        content: '均衡饮食是健康的基础...',
        category: '营养',
        createdAt: '2024-01-01T10:00:00'
      }
    ]
    knowledgeTotal.value = knowledgeList.value.length
    stats.totalKnowledge = knowledgeList.value.length
  } catch (error) {
    ElMessage.error('加载知识库失败：' + error.message)
  } finally {
    knowledgeLoading.value = false
  }
}

// 显示创建知识库对话框
const showCreateKnowledgeDialog = () => {
  knowledgeDialogMode.value = 'create'
  Object.assign(knowledgeForm, {
    id: null,
    title: '',
    content: '',
    category: ''
  })
  knowledgeDialogVisible.value = true
}

// 显示编辑知识库对话框
const showEditKnowledgeDialog = (kb) => {
  knowledgeDialogMode.value = 'edit'
  Object.assign(knowledgeForm, {
    id: kb.id,
    title: kb.title,
    content: kb.content,
    category: kb.category
  })
  knowledgeDialogVisible.value = true
}

// 保存知识库
const handleSaveKnowledge = async () => {
  if (!knowledgeForm.title || !knowledgeForm.content) {
    ElMessage.warning('请填写标题和内容')
    return
  }
  
  knowledgeSaving.value = true
  try {
    if (knowledgeDialogMode.value === 'create') {
      // await createKnowledgeAPI(knowledgeForm)
      ElMessage.success('知识库创建成功')
    } else {
      // await updateKnowledgeAPI(knowledgeForm.id, knowledgeForm)
      ElMessage.success('知识库更新成功')
    }
    
    knowledgeDialogVisible.value = false
    loadKnowledge()
  } catch (error) {
    ElMessage.error('保存失败：' + error.message)
  } finally {
    knowledgeSaving.value = false
  }
}

// 删除知识库
const handleDeleteKnowledge = async (kb) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除知识库 "${kb.title}" 吗？`,
      '删除确认',
      {
        type: 'warning',
        confirmButtonText: '确认删除',
        cancelButtonText: '取消'
      }
    )
    
    // await deleteKnowledgeAPI(kb.id)
    ElMessage.success('知识库已删除')
    loadKnowledge()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败：' + error.message)
    }
  }
}

// ==================== 工具函数 ====================
const getRoleName = (user) => {
  const roleMap = {
    'ROLE_ADMIN': '系统管理员',
    'ROLE_USER': '普通用户'
  }
  return roleMap[user.role] || user.role
}

const getRoleTagType = (user) => {
  return user.role === 'ROLE_ADMIN' ? 'danger' : 'success'
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  return dateStr.replace('T', ' ').substring(0, 19)
}

// 加载系统统计
const loadStats = async () => {
  try {
    // const res = await getSystemStatsAPI()
    // Object.assign(stats, res.data)
    stats.activeToday = Math.floor(Math.random() * 50)
  } catch (error) {
    console.error('加载统计失败：', error)
  }
}

// ==================== 生命周期 ====================
onMounted(() => {
  loadUsers()
  loadAgents()
  loadKnowledge()
  loadStats()
})
</script>

<style scoped>
.admin-container {
  padding: 20px;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  text-align: center;
}

.stat-card :deep(.el-statistic__head) {
  color: #666;
  font-size: 14px;
  margin-bottom: 8px;
}

.stat-card :deep(.el-statistic__content) {
  font-size: 28px;
  font-weight: bold;
  color: #409eff;
}

.tab-card {
  margin-top: 20px;
}

.tab-toolbar {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

:deep(.el-tabs__header) {
  margin-bottom: 20px;
}

:deep(.el-table) {
  font-size: 14px;
}

:deep(.el-pagination) {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
