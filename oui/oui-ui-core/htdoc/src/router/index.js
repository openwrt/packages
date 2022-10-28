import {createRouter, createWebHashHistory} from 'vue-router'
import addRoutesDev from './development.js'
import oui from '../oui'

function loadView(name) {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script')
    script.setAttribute('src', `/views/${name}.umd.js?_t=${new Date().getTime()}`)
    document.head.appendChild(script)

    script.addEventListener('load', () => {
      document.head.removeChild(script)
      resolve(window['oui-com-' + name])
    })

    script.addEventListener('error', () => {
      document.head.removeChild(script),
      reject()
    })
  })
}

const loginView = import.meta.env.VITE_OUI_LOGIN_VIEW || 'login'
const layoutView = import.meta.env.VITE_OUI_LAYOUT_VIEW || 'layout'
const homeView = import.meta.env.VITE_OUI_HOME_VIEW || 'home'

const routes = []

if (import.meta.env.MODE === 'development') {
  // eslint-disable-next-line no-undef
  const menus = oui.parseMenus(__MENUS__)
  addRoutesDev(routes, menus, loginView, layoutView, homeView)
} else {
  routes.push({
    path: '/login',
    name: 'login',
    component: () => loadView(loginView)
  })

  routes.push({
    path: '/',
    name: '/',
    component: () => loadView(layoutView),
    props: () => ({menus: oui.menus}),
    children: [
      {
        path: '/home',
        name: 'home',
        component: () => loadView(homeView)
      },
      {
        path: '/:pathMatch(.*)*',
        name: 'NotFound',
        component: () => import('../components/NotFound.vue')
      }
    ]
  })
}

function addRoutes(menu) {
  if (menu.view && menu.path !== '/')
    router.addRoute('/', {
      name: Symbol(),
      path: menu.path,
      component: () => loadView(menu.view),
      meta: { menu: menu }
    })
  else if (menu.children)
    menu.children.forEach(m => addRoutes(m))
}

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

router.beforeEach(async to => {
  await oui.init()

  if (to.path === '/login')
    return

  const authenticated = await oui.isAuthenticated()
  if (!authenticated)
    return '/login'

  await oui.initWithAuthed()

  if (import.meta.env.MODE === 'development')
    return

  if (!oui.menus) {
    router.getRoutes().forEach(r => {
      const name = r.name
      if (typeof(name) === 'string')
        return
      router.removeRoute(name)
    })
    const menus = await oui.loadMenus()
    menus.forEach(m => addRoutes(m))
    return to.fullPath
  }
})

router.afterEach(to => {
  if (to.path === '/')
    router.push('/home')
})

export default router
