<template>
  <div class="knowledge-page">
    <!-- 顶部操作栏 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">知识库</h2>
        <el-input
          v-model="searchKeyword"
          placeholder="搜索知识条目..."
          style="width: 300px"
          clearable
          @input="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
      </div>
      <el-button type="primary" @click="showCreateDialog">
        <el-icon><Plus /></el-icon>
        新建知识条目
      </el-button>
    </div>

    <!-- 内容区域 -->
    <div class="content-layout">
      <!-- 左侧分类树 -->
      <aside class="category-sidebar">
        <div class="sidebar-title">知识分类</div>
        <el-tree
          :data="categoryTree"
          :props="{ label: 'name', children: 'children' }"
          :default-expand-all="true"
          node-key="id"
          :highlight-current="true"
          @node-click="handleCategoryClick"
        >
          <template #default="{ node, data }">
            <div class="category-node">
              <el-icon><Folder /></el-icon>
              <span>{{ node.label }}</span>
              <el-tag size="small" type="info" class="count-tag">
                {{ data.count || 0 }}
              </el-tag>
            </div>
          </template>
        </el-tree>
      </aside>

      <!-- 右侧知识列表 -->
      <main class="knowledge-main">
        <el-table
          v-loading="loading"
          :data="filteredArticles"
          stripe
          style="width: 100%"
        >
          <el-table-column prop="title" label="标题" min-width="200">
            <template #default="{ row }">
              <div class="article-title">
                <el-icon><Document /></el-icon>
                <span>{{ row.title }}</span>
              </div>
            </template>
          </el-table-column>

          <el-table-column prop="categoryName" label="分类" width="150">
            <template #default="{ row }">
              <el-tag size="small" type="success">{{ row.categoryName }}</el-tag>
            </template>
          </el-table-column>

          <el-table-column prop="tags" label="标签" width="200">
            <template #default="{ row }">
              <el-tag
                v-for="tag in row.tags"
                :key="tag"
                size="small"
                type="info"
                effect="plain"
                style="margin-right: 4px"
              >
                {{ tag }}
              </el-tag>
            </template>
          </el-table-column>

          <el-table-column prop="updatedAt" label="更新时间" width="180">
            <template #default="{ row }">
              {{ formatDate(row.updatedAt) }}
            </template>
          </el-table-column>

          <el-table-column label="操作" width="150" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="editArticle(row)">
                编辑
              </el-button>
              <el-button link type="danger" size="small" @click="deleteArticle(row)">
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 空状态 -->
        <el-empty
          v-if="!loading && filteredArticles.length === 0"
          description="暂无知识条目"
          style="margin-top: 40px"
        />
      </main>
    </div>

    <!-- 创建/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px">
        <el-form-item label="标题" prop="title">
          <el-input
            v-model="formData.title"
            placeholder="请输入知识条目标题"
            maxlength="200"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="分类" prop="categoryId">
          <el-select v-model="formData.categoryId" placeholder="请选择分类" style="width: 100%">
            <el-option
              v-for="category in flatCategories"
              :key="category.id"
              :label="category.name"
              :value="category.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="标签">
          <el-select
            v-model="formData.tags"
            multiple
            filterable
            allow-create
            placeholder="选择或创建标签"
            style="width: 100%"
          >
            <el-option
              v-for="tag in commonTags"
              :key="tag"
              :label="tag"
              :value="tag"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="正文" prop="content">
          <el-input
            v-model="formData.content"
            type="textarea"
            :rows="10"
            placeholder="请输入知识内容,支持 Markdown 格式"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm" :loading="submitting">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Plus, Folder, Document } from '@element-plus/icons-vue'
import {
  getKBCategories,
  getKBArticles,
  createKBArticle,
  updateKBArticle,
  deleteKBArticle
} from '@/api/knowledge'

// 页面状态
const loading = ref(false)
const submitting = ref(false)
const searchKeyword = ref('')
const selectedCategoryId = ref(null)

// 数据
const categoryTree = ref([])
const articles = ref([])

// 对话框
const dialogVisible = ref(false)
const dialogTitle = computed(() => formData.id ? '编辑知识条目' : '新建知识条目')
const formRef = ref()

const formData = reactive({
  id: null,
  title: '',
  categoryId: null,
  tags: [],
  content: ''
})

const formRules = {
  title: [
    { required: true, message: '请输入标题', trigger: 'blur' }
  ],
  categoryId: [
    { required: true, message: '请选择分类', trigger: 'change' }
  ],
  content: [
    { required: true, message: '请输入正文', trigger: 'blur' }
  ]
}

// 常用标签
const commonTags = [
  '减脂', '增肌', '营养', '饮食', '运动', '健康',
  '心血管', '糖尿病', '睡眠', '心理健康'
]

// 扁平化的分类列表(用于选择器)
const flatCategories = computed(() => {
  const result = []
  const flatten = (list) => {
    list.forEach(item => {
      result.push({ id: item.id, name: item.name })
      if (item.children) {
        flatten(item.children)
      }
    })
  }
  flatten(categoryTree.value)
  return result
})

// 过滤后的文章列表
const filteredArticles = computed(() => {
  let result = articles.value

  // 按分类过滤
  if (selectedCategoryId.value) {
    result = result.filter(a => a.categoryId === selectedCategoryId.value)
  }

  // 按关键词过滤
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    result = result.filter(a =>
      a.title?.toLowerCase().includes(keyword) ||
      a.content?.toLowerCase().includes(keyword)
    )
  }

  return result
})

/**
 * 加载分类树
 */
const loadCategories = async () => {
  try {
    const response = await getKBCategories()
    categoryTree.value = response.data || []
  } catch (error) {
    console.error('加载分类失败:', error)
    ElMessage.error('加载分类失败')
  }
}

/**
 * 加载知识条目
 */
const loadArticles = async () => {
  loading.value = true
  try {
    const params = {}
    if (selectedCategoryId.value) {
      params.categoryId = selectedCategoryId.value
    }
    if (searchKeyword.value) {
      params.keyword = searchKeyword.value
    }

    const response = await getKBArticles(params)
    articles.value = response.data || []
  } catch (error) {
    console.error('加载知识条目失败:', error)
    ElMessage.error('加载知识条目失败')
  } finally {
    loading.value = false
  }
}

/**
 * 分类点击
 */
const handleCategoryClick = (data) => {
  selectedCategoryId.value = data.id
  loadArticles()
}

/**
 * 搜索
 */
const handleSearch = () => {
  loadArticles()
}

/**
 * 显示创建对话框
 */
const showCreateDialog = () => {
  formData.id = null
  formData.title = ''
  formData.categoryId = null
  formData.tags = []
  formData.content = ''
  dialogVisible.value = true
}

/**
 * 编辑文章
 */
const editArticle = (article) => {
  formData.id = article.id
  formData.title = article.title
  formData.categoryId = article.categoryId
  formData.tags = article.tags || []
  formData.content = article.content
  dialogVisible.value = true
}

/**
 * 删除文章
 */
const deleteArticle = async (article) => {
  try {
    await ElMessageBox.confirm(`确定要删除知识条目"${article.title}"吗?`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await deleteKBArticle(article.id)
    ElMessage.success('删除成功')
    loadArticles()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error('删除失败')
    }
  }
}

/**
 * 提交表单
 */
const submitForm = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    if (formData.id) {
      // 更新
      await updateKBArticle(formData.id, formData)
      ElMessage.success('更新成功')
    } else {
      // 创建
      await createKBArticle(formData)
      ElMessage.success('创建成功')
    }

    dialogVisible.value = false
    loadArticles()
  } catch (error) {
    console.error('保存失败:', error)
    ElMessage.error('保存失败')
  } finally {
    submitting.value = false
  }
}

/**
 * 格式化日期
 */
const formatDate = (dateString) => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN')
}

// 页面加载
onMounted(() => {
  loadCategories()
  loadArticles()
})
</script>

<style scoped lang="scss">
.knowledge-page {
  padding: 24px;
  min-height: calc(100vh - 60px);
  background: #f5f7fa;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 20px 24px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);

  .header-left {
    display: flex;
    align-items: center;
    gap: 20px;

    .page-title {
      margin: 0;
      font-size: 24px;
      font-weight: 600;
      color: #303133;
    }
  }
}

.content-layout {
  display: flex;
  gap: 20px;
}

.category-sidebar {
  width: 260px;
  flex-shrink: 0;
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
  height: fit-content;

  .sidebar-title {
    font-size: 16px;
    font-weight: 600;
    color: #303133;
    margin-bottom: 16px;
  }

  :deep(.el-tree) {
    background: transparent;
  }

  .category-node {
    display: flex;
    align-items: center;
    gap: 8px;
    flex: 1;

    .el-icon {
      color: #909399;
    }

    .count-tag {
      margin-left: auto;
    }
  }
}

.knowledge-main {
  flex: 1;
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);

  .article-title {
    display: flex;
    align-items: center;
    gap: 8px;

    .el-icon {
      color: #909399;
    }
  }
}
</style>
