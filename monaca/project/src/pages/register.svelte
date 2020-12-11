<Page name="register">
  <Navbar title="GPSトラッカー（仮）へ登録"></Navbar>
  <List noHairlinesMd>
    <ListInput
      label="お名前"
      type="text"
      placeholder="鈴木　愛"
    ></ListInput>
    <ListInput
      label="メールアドレス"
      type="text"
      placeholder="ai_suzuki@example.co.jp"
    ></ListInput>
    <ListInput
      label="電話番号"
      type="text"
      placeholder="090-000-0000"
    ></ListInput>
    <ListInput
      label="ログインID"
      type="text"
      placeholder="johndoe"
    ></ListInput>
    <ListInput
      label="パスワード"
      type="password"
      placeholder="Password"
    ></ListInput>
    <ListInput
      label="パスワードの確認"
      type="password"
      placeholder="Password"
    ></ListInput>
    <ListItem
      checkbox
      name="my-checkbox"
      value="1"
      title="パスワードを表示"
    ></ListItem>
  </List>
  <Block>
    <Button class="link" fill href="/auth/">登録</Button>
  </Block>
</Page>
<script>
  import {
    Page,
    Navbar,
    List,
    ListInput,
    ListItem,
    Toggle,
    BlockTitle,
    Row,
    Button,
    Range,
    Block
  } from 'framework7-svelte';
</script>
