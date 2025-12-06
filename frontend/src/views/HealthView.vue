<template>
  <div class="health-view">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-content">
        <div>
          <h1>健康档案</h1>
          <p>记录和追踪您的健康数据变化</p>
        </div>
        <el-button type="primary" size="large" @click="showAddDialog = true">
          <el-icon><Plus /></el-icon>
          添加记录
        </el-button>
      </div>
    </div>

    <!-- 健康概览卡片 -->
    <div class="overview-section">
      <div class="overview-card weight-card">
        <div class="card-icon">
          <el-icon :size="28"><ScaleToOriginal /></el-icon>
        </div>
        <div class="card-info">
          <span class="card-label">当前体重</span>
          <div class="card-value">
            <span class="value">{{ currentWeight }}</span>
            <span class="unit">kg</span>
          </div>
          <span class="card-trend up">
            <el-icon><Top /></el-icon>
            较上次 +0.5kg
          </span>
        </div>
      </div>

      <div class="overview-card bmi-card">
        <div class="card-icon">
          <el-icon :size="28"><DataLine /></el-icon>
        </div>
        <div class="card-info">
          <span class="card-label">BMI 指数</span>
          <div class="card-value">
            <span class="value">{{ bmiValue }}</span>
          </div>
          <span class="card-status normal">正常范围</span>
        </div>
      </div>

      <div class="overview-card workout-card">
        <div class="card-icon">
          <el-icon :size="28"><Timer /></el-icon>
        </div>
        <div class="card-info">
          <span class="card-label">本周运动</span>
          <div class="card-value">
            <span class="value">{{ weeklyWorkout }}</span>
            <span class="unit">次</span>
          </div>
          <span class="card-trend">
            累计 {{ weeklyMinutes }} 分钟
          </span>
        </div>
      </div>

      <div class="overview-card goal-card">
        <div class="card-icon">
          <el-icon :size="28"><Aim /></el-icon>
        </div>
        <div class="card-info">
          <span class="card-label">目标进度</span>
          <div class="card-value">
            <span class="value">{{ goalProgress }}</span>
            <span class="unit">%</span>
          </div>
          <el-progress :percentage="goalProgress" :show-text="false" />
        </div>
      </div>
    </div>

    <!-- 数据记录区域 -->
    <div class="records-section">
      <!-- 左侧 - 体重记录 -->
      <div class="records-panel">
        <div class="panel-header">
          <h3>
            <el-icon><ScaleToOriginal /></el-icon>
            体重记录
          </h3>
          <el-radio-group v-model="weightPeriod" size="small">
            <el-radio-button label="week">本周</el-radio-button>
            <el-radio-button label="month">本月</el-radio-button>
            <el-radio-button label="year">今年</el-radio-button>
          </el-radio-group>
        </div>
        
        <!-- 体重趋势图占位 -->
        <div class="chart-placeholder">
          <div class="chart-mock">
            <svg viewBox="0 0 400 200" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M20 160 L80 140 L140 150 L200 120 L260 130 L320 100 L380 110" 
                    stroke="#667eea" stroke-width="3" fill="none" stroke-linecap="round"/>
              <circle cx="20" cy="160" r="4" fill="#667eea"/>
              <circle cx="80" cy="140" r="4" fill="#667eea"/>
              <circle cx="140" cy="150" r="4" fill="#667eea"/>
              <circle cx="200" cy="120" r="4" fill="#667eea"/>
              <circle cx="260" cy="130" r="4" fill="#667eea"/>
              <circle cx="320" cy="100" r="4" fill="#667eea"/>
              <circle cx="380" cy="110" r="4" fill="#667eea"/>
            </svg>
          </div>
          <p class="chart-tip">体重变化趋势图</p>
        </div>

        <!-- 体重记录列表 -->
        <div class="records-list">
          <div class="record-item" v-for="record in weightRecords" :key="record.id">
            <div class="record-date">
              <span class="day">{{ record.day }}</span>
              <span class="month">{{ record.month }}</span>
            </div>
            <div class="record-info">
              <span class="record-value">{{ record.weight }} kg</span>
              <span class="record-note">{{ record.note || '无备注' }}</span>
            </div>
            <div class="record-change" :class="record.change > 0 ? 'up' : 'down'">
              {{ record.change > 0 ? '+' : '' }}{{ record.change }} kg
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧 - 运动记录 -->
      <div class="records-panel">
        <div class="panel-header">
          <h3>
            <el-icon><Bicycle /></el-icon>
            运动记录
          </h3>
          <el-button text type="primary" @click="showWorkoutDialog = true">
            <el-icon><Plus /></el-icon>
            添加
          </el-button>
        </div>

        <!-- 运动记录列表 -->
        <div class="workout-list">
          <div class="workout-item" v-for="workout in workoutRecords" :key="workout.id">
            <div class="workout-icon" :class="workout.type">
              <el-icon v-if="workout.type === 'running'"><Position /></el-icon>
              <el-icon v-else-if="workout.type === 'cycling'"><Bicycle /></el-icon>
              <el-icon v-else-if="workout.type === 'swimming'"><Ship /></el-icon>
              <el-icon v-else><Football /></el-icon>
            </div>
            <div class="workout-info">
              <span class="workout-name">{{ workout.name }}</span>
              <span class="workout-date">{{ workout.date }}</span>
            </div>
            <div class="workout-stats">
              <div class="stat">
                <span class="stat-value">{{ workout.duration }}</span>
                <span class="stat-label">分钟</span>
              </div>
              <div class="stat">
                <span class="stat-value">{{ workout.calories }}</span>
                <span class="stat-label">千卡</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 本周运动统计 -->
        <div class="weekly-summary">
          <h4>本周统计</h4>
          <div class="summary-grid">
            <div class="summary-item">
              <span class="summary-value">{{ weeklyWorkout }}</span>
              <span class="summary-label">运动次数</span>
            </div>
            <div class="summary-item">
              <span class="summary-value">{{ weeklyMinutes }}</span>
              <span class="summary-label">总时长(分)</span>
            </div>
            <div class="summary-item">
              <span class="summary-value">{{ weeklyCalories }}</span>
              <span class="summary-label">消耗(千卡)</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 添加体重记录对话框 -->
    <el-dialog v-model="showAddDialog" title="添加体重记录" width="480px">
      <el-form :model="weightForm" label-position="top">
        <el-form-item label="体重 (kg)">
          <el-input-number 
            v-model="weightForm.weight" 
            :precision="1" 
            :step="0.1" 
            :min="30" 
            :max="200"
            size="large"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="记录日期">
          <el-date-picker 
            v-model="weightForm.recordDate" 
            type="date" 
            placeholder="选择日期"
            size="large"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="备注">
          <el-input 
            v-model="weightForm.note" 
            type="textarea" 
            :rows="3"
            placeholder="可选，添加备注信息"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="handleAddWeight">保存</el-button>
      </template>
    </el-dialog>

    <!-- 添加运动记录对话框 -->
    <el-dialog v-model="showWorkoutDialog" title="添加运动记录" width="480px">
      <el-form :model="workoutForm" label-position="top">
        <el-form-item label="运动类型">
          <el-select 
            v-model="workoutForm.workoutType" 
            placeholder="请选择运动类型"
            size="large"
            style="width: 100%"
          >
            <el-option label="跑步" value="running" />
            <el-option label="骑行" value="cycling" />
            <el-option label="游泳" value="swimming" />
            <el-option label="力量训练" value="strength" />
            <el-option label="瑜伽" value="yoga" />
            <el-option label="其他" value="other" />
          </el-select>
        </el-form-item>
        <el-form-item label="运动时长 (分钟)">
          <el-input-number 
            v-model="workoutForm.duration" 
            :min="1" 
            :max="300"
            size="large"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="消耗卡路里 (可选)">
          <el-input-number 
            v-model="workoutForm.calories" 
            :min="0" 
            :max="2000"
            size="large"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="运动日期">
          <el-date-picker 
            v-model="workoutForm.workoutDate" 
            type="date" 
            placeholder="选择日期"
            size="large"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="备注">
          <el-input 
            v-model="workoutForm.note" 
            type="textarea" 
            :rows="3"
            placeholder="可选，添加备注信息"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showWorkoutDialog = false">取消</el-button>
        <el-button type="primary" @click="handleAddWorkout">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  Plus, 
  ScaleToOriginal, 
  DataLine, 
  Timer, 
  Aim, 
  Top,
  Bicycle,
  Position,
  Ship,
  Football
} from '@element-plus/icons-vue'
import {
  getHealthProfileAPI,
  getWeightLogsAPI,
  getLatestWeightAPI,
  addWeightLogAPI,
  getWorkoutLogsAPI,
  getWeeklySummaryAPI,
  addWorkoutLogAPI
} from '@/api/health'

// 健康档案数据
const healthProfile = ref(null)

// 概览数据
const currentWeight = ref(0)
const bmiValue = ref(0)
const weeklyWorkout = ref(0)
const weeklyMinutes = ref(0)
const weeklyCalories = ref(0)
const goalProgress = computed(() => {
  if (!healthProfile.value?.weeklyWorkoutDays) return 0
  return Math.round((weeklyWorkout.value / healthProfile.value.weeklyWorkoutDays) * 100)
})

const weightPeriod = ref('week')
const showAddDialog = ref(false)
const showWorkoutDialog = ref(false)

// 体重记录表单
const weightForm = reactive({
  weight: null,
  recordDate: new Date(),
  note: ''
})

// 运动记录表单
const workoutForm = reactive({
  workoutType: '',
  duration: null,
  calories: null,
  workoutDate: new Date(),
  note: ''
})

// 体重记录列表
const weightRecords = ref([])
const rawWeightRecords = ref([])

// 运动记录列表
const workoutRecords = ref([])

// 加载健康档案
const loadHealthProfile = async () => {
  try {
    const data = await getHealthProfileAPI()
    healthProfile.value = data
    if (data?.bmi) {
      bmiValue.value = data.bmi
    }
  } catch (error) {
    console.error('获取健康档案失败:', error)
  }
}

// 加载最新体重
const loadLatestWeight = async () => {
  try {
    const data = await getLatestWeightAPI()
    if (data?.weight) {
      currentWeight.value = data.weight
    }
  } catch (error) {
    console.error('获取最新体重失败:', error)
  }
}

// 加载体重记录
const loadWeightLogs = async () => {
  try {
    const params = {}
    const now = new Date()
    
    if (weightPeriod.value === 'week') {
      const startOfWeek = new Date(now)
      startOfWeek.setDate(now.getDate() - now.getDay())
      params.startDate = startOfWeek.toISOString().split('T')[0]
    } else if (weightPeriod.value === 'month') {
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)
      params.startDate = startOfMonth.toISOString().split('T')[0]
    } else if (weightPeriod.value === 'year') {
      const startOfYear = new Date(now.getFullYear(), 0, 1)
      params.startDate = startOfYear.toISOString().split('T')[0]
    }
    
    const data = await getWeightLogsAPI(params)
    rawWeightRecords.value = data || []
    
    // 格式化数据用于显示
    weightRecords.value = (data || []).map((record, index) => {
      const date = new Date(record.recordDate)
      const prevWeight = index < data.length - 1 ? data[index + 1].weight : record.weight
      const change = (record.weight - prevWeight).toFixed(1)
      
      return {
        id: record.id,
        day: String(date.getDate()).padStart(2, '0'),
        month: `${date.getMonth() + 1}月`,
        weight: record.weight,
        change: parseFloat(change),
        note: record.note || ''
      }
    })
  } catch (error) {
    console.error('获取体重记录失败:', error)
  }
}

// 加载本周运动统计
const loadWeeklySummary = async () => {
  try {
    const data = await getWeeklySummaryAPI()
    if (data) {
      weeklyWorkout.value = data.totalWorkouts || 0
      weeklyMinutes.value = data.totalMinutes || 0
      weeklyCalories.value = data.totalCalories || 0
    }
  } catch (error) {
    console.error('获取运动统计失败:', error)
  }
}

// 加载运动记录
const loadWorkoutLogs = async () => {
  try {
    const now = new Date()
    const startOfWeek = new Date(now)
    startOfWeek.setDate(now.getDate() - now.getDay())
    
    const params = {
      startDate: startOfWeek.toISOString().split('T')[0]
    }
    
    const data = await getWorkoutLogsAPI(params)
    
    // 格式化数据用于显示
    workoutRecords.value = (data || []).map(record => {
      const workoutDate = new Date(record.workoutDate)
      const today = new Date()
      const yesterday = new Date(today)
      yesterday.setDate(today.getDate() - 1)
      
      let dateStr
      if (workoutDate.toDateString() === today.toDateString()) {
        dateStr = '今天'
      } else if (workoutDate.toDateString() === yesterday.toDateString()) {
        dateStr = '昨天'
      } else {
        dateStr = `${workoutDate.getMonth() + 1}月${String(workoutDate.getDate()).padStart(2, '0')}日`
      }
      
      const typeMap = {
        'running': { type: 'running', name: '跑步' },
        'cycling': { type: 'cycling', name: '骑行' },
        'swimming': { type: 'swimming', name: '游泳' },
        'strength': { type: 'other', name: '力量训练' },
        'yoga': { type: 'other', name: '瑜伽' },
        'other': { type: 'other', name: '其他运动' }
      }
      
      const typeInfo = typeMap[record.workoutType] || typeMap['other']
      
      return {
        id: record.id,
        type: typeInfo.type,
        name: typeInfo.name,
        date: dateStr,
        duration: record.duration || 0,
        calories: record.calories || 0
      }
    })
  } catch (error) {
    console.error('获取运动记录失败:', error)
  }
}

// 添加体重记录
const handleAddWeight = async () => {
  if (!weightForm.weight) {
    ElMessage.warning('请输入体重')
    return
  }
  
  try {
    await addWeightLogAPI({
      weight: weightForm.weight,
      recordDate: weightForm.recordDate ? new Date(weightForm.recordDate).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
      note: weightForm.note
    })
    
    ElMessage.success('体重记录已保存')
    showAddDialog.value = false
    
    // 重新加载数据
    await loadLatestWeight()
    await loadWeightLogs()
    
    // 重置表单
    weightForm.weight = null
    weightForm.recordDate = new Date()
    weightForm.note = ''
  } catch (error) {
    console.error('添加体重记录失败:', error)
    ElMessage.error('保存失败，请重试')
  }
}

// 添加运动记录
const handleAddWorkout = async () => {
  if (!workoutForm.workoutType || !workoutForm.duration) {
    ElMessage.warning('请填写运动类型和时长')
    return
  }
  
  try {
    await addWorkoutLogAPI({
      workoutType: workoutForm.workoutType,
      duration: workoutForm.duration,
      calories: workoutForm.calories,
      workoutDate: workoutForm.workoutDate ? new Date(workoutForm.workoutDate).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
      note: workoutForm.note
    })
    
    ElMessage.success('运动记录已保存')
    showWorkoutDialog.value = false
    
    // 重新加载数据
    await loadWorkoutLogs()
    await loadWeeklySummary()
    
    // 重置表单
    workoutForm.workoutType = ''
    workoutForm.duration = null
    workoutForm.calories = null
    workoutForm.workoutDate = new Date()
    workoutForm.note = ''
  } catch (error) {
    console.error('添加运动记录失败:', error)
    ElMessage.error('保存失败，请重试')
  }
}

// 初始化加载数据
onMounted(async () => {
  await Promise.all([
    loadHealthProfile(),
    loadLatestWeight(),
    loadWeightLogs(),
    loadWorkoutLogs(),
    loadWeeklySummary()
  ])
})
</script>

<style scoped lang="scss">
.health-view {
  width: 100%;
  min-height: 100%;
}

.page-header {
  margin-bottom: 32px;
  
  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  h1 {
    font-size: 28px;
    font-weight: 700;
    color: #1a1a2e;
    margin: 0 0 8px;
  }
  
  p {
    font-size: 15px;
    color: #6b7280;
    margin: 0;
  }
  
  .el-button {
    border-radius: 12px;
  }
}

/* 概览卡片 */
.overview-section {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  margin-bottom: 32px;
}

.overview-card {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: flex-start;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  
  .card-icon {
    width: 56px;
    height: 56px;
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    margin-right: 16px;
    flex-shrink: 0;
  }
  
  &.weight-card .card-icon {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }
  
  &.bmi-card .card-icon {
    background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  }
  
  &.workout-card .card-icon {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  }
  
  &.goal-card .card-icon {
    background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  }
  
  .card-info {
    flex: 1;
    
    .card-label {
      font-size: 13px;
      color: #9ca3af;
      display: block;
      margin-bottom: 6px;
    }
    
    .card-value {
      margin-bottom: 8px;
      
      .value {
        font-size: 28px;
        font-weight: 700;
        color: #1a1a2e;
      }
      
      .unit {
        font-size: 14px;
        color: #6b7280;
        margin-left: 4px;
      }
    }
    
    .card-trend {
      font-size: 12px;
      color: #6b7280;
      display: flex;
      align-items: center;
      gap: 4px;
      
      &.up {
        color: #ef4444;
      }
      
      &.down {
        color: #10b981;
      }
    }
    
    .card-status {
      font-size: 12px;
      padding: 2px 8px;
      border-radius: 4px;
      
      &.normal {
        background: #dcfce7;
        color: #16a34a;
      }
    }
    
    .el-progress {
      margin-top: 4px;
    }
  }
}

/* 记录区域 */
.records-section {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
}

.records-panel {
  background: #fff;
  border-radius: 20px;
  padding: 28px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  
  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    
    h3 {
      font-size: 18px;
      font-weight: 600;
      color: #1a1a2e;
      margin: 0;
      display: flex;
      align-items: center;
      gap: 8px;
      
      .el-icon {
        color: #667eea;
      }
    }
  }
}

/* 图表占位 */
.chart-placeholder {
  background: #f9fafb;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
  
  .chart-mock {
    height: 160px;
    display: flex;
    align-items: center;
    justify-content: center;
    
    svg {
      width: 100%;
      max-width: 400px;
      height: auto;
    }
  }
  
  .chart-tip {
    text-align: center;
    font-size: 13px;
    color: #9ca3af;
    margin: 12px 0 0;
  }
}

/* 体重记录列表 */
.records-list {
  .record-item {
    display: flex;
    align-items: center;
    padding: 16px 0;
    border-bottom: 1px solid #f0f0f0;
    
    &:last-child {
      border-bottom: none;
    }
    
    .record-date {
      width: 56px;
      text-align: center;
      
      .day {
        display: block;
        font-size: 20px;
        font-weight: 600;
        color: #1a1a2e;
      }
      
      .month {
        font-size: 12px;
        color: #9ca3af;
      }
    }
    
    .record-info {
      flex: 1;
      margin-left: 16px;
      
      .record-value {
        display: block;
        font-size: 16px;
        font-weight: 600;
        color: #1a1a2e;
      }
      
      .record-note {
        font-size: 13px;
        color: #9ca3af;
      }
    }
    
    .record-change {
      font-size: 14px;
      font-weight: 500;
      
      &.up {
        color: #ef4444;
      }
      
      &.down {
        color: #10b981;
      }
    }
  }
}

/* 运动记录列表 */
.workout-list {
  .workout-item {
    display: flex;
    align-items: center;
    padding: 16px;
    background: #f9fafb;
    border-radius: 12px;
    margin-bottom: 12px;
    
    .workout-icon {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-size: 24px;
      
      &.running {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      }
      
      &.cycling {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
      }
      
      &.swimming {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
      }
      
      &.other {
        background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
      }
    }
    
    .workout-info {
      flex: 1;
      margin-left: 16px;
      
      .workout-name {
        display: block;
        font-size: 15px;
        font-weight: 600;
        color: #1a1a2e;
      }
      
      .workout-date {
        font-size: 13px;
        color: #9ca3af;
      }
    }
    
    .workout-stats {
      display: flex;
      gap: 20px;
      
      .stat {
        text-align: center;
        
        .stat-value {
          display: block;
          font-size: 18px;
          font-weight: 600;
          color: #1a1a2e;
        }
        
        .stat-label {
          font-size: 12px;
          color: #9ca3af;
        }
      }
    }
  }
}

/* 周统计 */
.weekly-summary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  padding: 20px;
  margin-top: 20px;
  
  h4 {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.85);
    margin: 0 0 16px;
    font-weight: 500;
  }
  
  .summary-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    
    .summary-item {
      text-align: center;
      
      .summary-value {
        display: block;
        font-size: 24px;
        font-weight: 700;
        color: #fff;
      }
      
      .summary-label {
        font-size: 12px;
        color: rgba(255, 255, 255, 0.75);
      }
    }
  }
}

/* 响应式适配 */
@media (max-width: 1200px) {
  .overview-section {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 968px) {
  .records-section {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .overview-section {
    grid-template-columns: 1fr;
  }
  
  .page-header .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
}
</style>
