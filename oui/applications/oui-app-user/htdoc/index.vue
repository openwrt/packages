<template>
  <n-button type="primary" @click="showAdd">{{ $t('Add user') }}</n-button>
  <n-modal v-model:show="model" preset="dialog" :title="modify ? $t('Change') : $t('Add user')"
    :positive-text="$t('OK')"
    :negative-text="$t('Cancel')"
    @positive-click="addUser">
    <n-form ref="form" :model="formValue" :rules="rules" label-placement="left" label-width="auto">
      <n-form-item :label="$t('Username')" path="username">
        <n-input v-model:value="formValue.username" :readonly="modify !== ''"/>
      </n-form-item>
      <n-form-item :label="$t('Password')" path="password" type="password" show-password-on="mousedown">
        <n-input v-model:value="formValue.password"/>
      </n-form-item>
      <n-form-item :label="$t('ACL group')" path="acl">
        <n-select v-model:value="formValue.acl" :options="aclGroups"/>
      </n-form-item>
    </n-form>
  </n-modal>
  <n-divider></n-divider>
  <n-data-table :row-key="r => r.id" :columns="columns" :data="users"/>
</template>

<script>
import { h, resolveComponent } from 'vue'

export default {
  data() {
    return {
      model: false,
      modify: '',
      columns: [
        {
          title: () => this.$t('Username'),
          key: 'username'
        },
        {
          key: 'actions',
          render: r => h(resolveComponent('n-space'), () => [
            h(resolveComponent('n-button'), { type: 'primary', onClick: () => this.modifyUser(r) }, () => this.$t('Change')),
            h(resolveComponent('n-button'), { type: 'error', onClick: () => this.deleteUser(r) }, () => this.$t('Delete'))
          ])
        }
      ],
      users: [],
      rules: {
        username: {
          required: true,
          trigger: 'blur',
          message: () => this.$t('This field is required')
        },
        password: {
          required: true,
          trigger: 'blur',
          message: () => this.$t('This field is required')
        },
        acl: {
          required: true,
          trigger: 'blur',
          message: () => this.$t('This field is required')
        }
      },
      formValue: {
        username: '',
        password: '',
        acl: ''
      },
      aclGroups: []
    }
  },
  methods: {
    getUsers() {
      this.$oui.call('user', 'get_users').then(({ users }) => {
        this.users = users
      })
    },
    deleteUser(user) {
      this.$dialog.create({
        content: this.$t('delete-user-confirm', { username: user.username }),
        negativeText: this.$t('Cancel'),
        positiveText: this.$t('OK'),
        onPositiveClick: () => {
          this.$oui.call('user', 'del_user', { id: user.id }).then(() => this.getUsers())
        }
      })
    },
    showAdd() {
      this.modify = ''
      this.formValue.username = ''
      this.formValue.password = ''
      this.formValue.acl = ''
      this.model = true
    },
    addUser() {
      return new Promise((resolve, reject) => {
        this.$refs.form.validate(errors => {
          if (errors) {
            reject()
            return
          }

          if (this.modify) {
            this.$oui.call('user', 'change', {
              password: this.formValue.password,
              acl: this.formValue.acl,
              id: this.modify
            })
            resolve()
          } else {
            this.$oui.call('user', 'add_user', {
              username: this.formValue.username,
              password: this.formValue.password,
              acl: this.formValue.acl
            }).then(({ code }) => {
              if (code === 0) {
                resolve()
                this.getUsers()
              } else {
                reject()
                this.$message.error(this.$t('username-exist', { username: this.formValue.username }))
              }
            })
          }
        })
      })
    },
    modifyUser(r) {
      this.modify = r.id
      this.formValue.username = r.username
      this.formValue.password = ''
      this.formValue.acl = r.acl
      this.model = true
    }
  },
  created() {
    this.getUsers()
    this.$oui.call('acl', 'load').then(acls => {
      this.aclGroups = Object.keys(acls).map(group => {
        return {
          label: group,
          value: group
        }
      })
    })
  }
}
</script>

<i18n src="./locale.json"/>
