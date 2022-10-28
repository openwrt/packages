<template>
  <n-el style="background-color: var(--base-color); opacity: 0.8; width: 100%; height: 100vh;">
    <n-form class="login" size="large" ref="form" :model="formValue" :rules="rules">
      <n-form-item path="username">
        <n-input v-model:value="formValue.username" :placeholder="$t('Please enter username')">
          <template #prefix>
            <n-icon size="18" color="#808695"><person-outline/></n-icon>
          </template>
        </n-input>
      </n-form-item>
      <n-form-item path="password">
        <n-input v-model:value="formValue.password" :placeholder="$t('Please enter password')" type="password" show-password-on="mousedown">
          <template #prefix>
            <n-icon size="18" color="#808695"><lock-closed-outline/></n-icon>
          </template>
        </n-input>
      </n-form-item>
      <n-form-item>
        <n-button type="primary" block :loading="loading" @click="handleSubmit">{{ $t('Login') }}</n-button>
      </n-form-item>
      <div class="copyright">
        <n-text type="info">Copyright © 2022 Powered by </n-text>
        <n-a href="https://github.com/zhaojh329/oui" target="_blank">oui</n-a>
      </div>
    </n-form>
  </n-el>
</template>

<script>
import { PersonOutline, LockClosedOutline } from '@vicons/ionicons5'

export default {
  components: {
    PersonOutline,
    LockClosedOutline
  },
  data() {
    return {
      loading: false,
      formValue: {
        username: '',
        password: ''
      },
      rules: {
        username: {
          required: true,
          trigger: 'blur',
          message: () => this.$t('Please enter username')
        }
      }
    }
  },
  methods: {
    handleSubmit() {
      this.$refs.form.validate(async errors => {
        if (errors)
          return

        this.loading = true

        try {
          await this.$oui.login(this.formValue.username, this.formValue.password)
          this.$router.push('/')
        } catch {
          this.$message.error(this.$t('wrong username or password'))
        }

        this.loading = false
      })
    }
  }
}
</script>

<style scoped>
.login {
  width: 400px;
  top: 40%;
  left: 50%;
  position: fixed;
  transform: translate(-50%, -50%);
}

.copyright {
  text-align: center;
  font-size: medium;
}

.copyright .n-a {
  font-size: 1.2em;
}
</style>

<i18n src="./locale.json"/>
