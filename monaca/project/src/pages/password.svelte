<Page name="register">
  <Navbar title="GPSトラッカー（仮）パスワード再発行<"></Navbar>
  <List noHairlinesMd>
    <ListInput
      label="メールアドレス"
      type="text"
      placeholder="ai_suzuki@example.co.jp"
    ></ListInput>
  </List>
  <Block>
    <p><Link class="back">ログイン画面に戻る</Link></p>
    <Button class="link" fill href="/">再発行</Button>
  </Block>
</Page>
<script>
  import {
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
