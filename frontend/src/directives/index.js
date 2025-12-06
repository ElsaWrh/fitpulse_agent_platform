/**
 * 自定义指令统一导出
 */
import loading from './loading'

export default {
  install(app) {
    app.directive('loading', loading)
  }
}
