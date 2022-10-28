function addRoutes(r, menu) {
  if (menu.view && menu.path !== '/') {
    r.push({
      path: menu.path,
      component: () => import(`../applications/oui-app-${menu.view}/htdoc/index.vue`),
      meta: { menu: menu }
    })
  } else if (menu.children) {
    menu.children.forEach(m => addRoutes(r, m))
  }
}

export default function(routes, menus, loginView, layoutView, homeView) {
  routes.push({
    path: '/login',
    name: 'login',
    component: () => import(`../applications/oui-app-${loginView}/htdoc/index.vue`)
  })

  routes.push({
    path: '/',
    name: '/',
    component: () => import(`../applications/oui-app-${layoutView}/htdoc/index.vue`),
    props: () => ({menus: menus}),
    children: [
      {
        path: '/home',
        name: 'home',
        component: () => import(`../applications/oui-app-${homeView}/htdoc/index.vue`)
      },
      {
        path: '/:pathMatch(.*)*',
        name: 'NotFound',
        component: () => import('../components/NotFound.vue')
      }
    ]
  })

  menus.forEach(menu => addRoutes(routes[1].children, menu))
}
