/**
 * 加载状态组合式函数
 */
import { ref } from 'vue'

export function useLoading(initialValue = false) {
  const loading = ref(initialValue)

  const setLoading = (value) => {
    loading.value = value
  }

  const startLoading = () => {
    loading.value = true
  }

  const stopLoading = () => {
    loading.value = false
  }

  return {
    loading,
    setLoading,
    startLoading,
    stopLoading
  }
}
