/**
 * 加载指令
 * 使用方式: v-loading="loading"
 */
export default {
  mounted(el, binding) {
    if (binding.value) {
      el.classList.add('is-loading')
    }
  },
  updated(el, binding) {
    if (binding.value) {
      el.classList.add('is-loading')
    } else {
      el.classList.remove('is-loading')
    }
  }
}
