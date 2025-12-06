/**
 * 对话框组合式函数
 */
import { ref } from 'vue'

export function useDialog() {
  const visible = ref(false)

  const open = () => {
    visible.value = true
  }

  const close = () => {
    visible.value = false
  }

  const toggle = () => {
    visible.value = !visible.value
  }

  return {
    visible,
    open,
    close,
    toggle
  }
}
