/**
 * 分页组合式函数
 */
import { ref, computed } from 'vue'
import { PAGINATION } from '@/constants'

export function usePagination(options = {}) {
  const {
    defaultPage = PAGINATION.DEFAULT_PAGE,
    defaultSize = PAGINATION.DEFAULT_SIZE
  } = options

  const currentPage = ref(defaultPage)
  const pageSize = ref(defaultSize)
  const total = ref(0)

  const totalPages = computed(() => {
    return Math.ceil(total.value / pageSize.value)
  })

  const handleSizeChange = (size) => {
    pageSize.value = size
    currentPage.value = 1
  }

  const handleCurrentChange = (page) => {
    currentPage.value = page
  }

  const resetPagination = () => {
    currentPage.value = defaultPage
    pageSize.value = defaultSize
    total.value = 0
  }

  return {
    currentPage,
    pageSize,
    total,
    totalPages,
    handleSizeChange,
    handleCurrentChange,
    resetPagination
  }
}
