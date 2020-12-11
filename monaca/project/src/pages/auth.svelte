<Page name="register">
  <Navbar title="GPSトラッカー（仮）へ登録"></Navbar>
  <List noHairlinesMd>
    <ListInput
      label="メールアドレスのコード"
      type="text"
      placeholder="12345678"
    ></ListInput>
    <ListInput
      label="SNSのコード"
      type="text"
      placeholder="87654321"
    ></ListInput>
  </List>
  <Block>
    <Row tag="p">
      <Button class="col link" fill href="/map/">確認</Button>
    </Row>
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
