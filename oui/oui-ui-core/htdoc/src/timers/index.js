class timer {
  constructor() {
    this.timers = {}
  }

  create(name, callback, options) {
    if (this.timers[name])
      throw new Error(`[timer.create] name '${name}' is conflicting`)

    this.timers[name] = {
      callback: callback,
      ...options
    }

    const timer = this.timers[name]

    if (typeof timer.time !== 'number')
      timer.time = 1000

    if (timer.autostart === undefined || timer.autostart)
      this.start(name)

    if (timer.immediate)
      timer.callback()
  }

  start(name) {
    if (!this.timers[name])
      throw new Error(`[timer.start] '${name}' not found`)

    const timer = this.timers[name]

    if (timer.instance)
      return

    if (timer.repeat)
      timer.instance = setInterval(timer.callback, timer.time)
    else
      timer.instance = setTimeout(timer.callback, timer.time)
  }

  stop(name) {
    if (!this.timers[name])
      return

    const timer = this.timers[name]
    if (!timer.instance)
      return

    if (timer.repeat)
      clearInterval(timer.instance)
    else
      clearTimeout(timer.instance)

    timer.instance = undefined
  }
}

export default {
  install: app => {
    app.mixin({
      created() {
        this.$timer = new timer()
      },
      beforeUnmount() {
        Object.keys(this.$timer.timers).forEach(name => this.$timer.stop(name))
        this.$timer.timers = {}
      }
    })
  }
}
