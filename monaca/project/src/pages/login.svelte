<Page name="login">
  <Navbar title="GPSトラッカー（仮）へようこそ"></Navbar>
  <List noHairlinesMd>
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
    <ListItem
      checkbox
      name="my-checkbox"
      value="1"
      title="パスワードを表示"
    ></ListItem>
  </List>
  <Block>
    <Button class="link" fill href="/map/">ログイン</Button>
    <p class="text-center"><Link class="link" href="/password/">ID・パスワードを忘れた方</Link></p>
  </Block>
  <Block strong>
    <p class="text-center">新規ユーザー登録</p>
    <Button class="link" fill href="/register/">登録</Button>
  </Block>
</Page>
<script>
  import {
    Icon,
    Page,
    Navbar,
    List,
    ListInput,
    ListItem,
    Link,
    Toggle,
    BlockTitle,
    Row,
    Button,
    Range,
    Block
  } from 'framework7-svelte';
</script>
