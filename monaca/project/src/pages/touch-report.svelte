<Page name="touchReport">
  <Navbar title="鈴木愛さんの過去14日間の接触を会社に報告" backLink="Back"></Navbar>
  <List noHairlinesMd>
    <ListInput
      label="会社ID"
      type="text"
      placeholder="TRACKER.CO"
    ></ListInput>
    <ListInput
      label="キー"
      type="password"
      placeholder="Password"
    ></ListInput>
    <ListItem
      checkbox
      name="my-checkbox"
      value="1"
      title="キーを表示"
    ></ListItem>
  </List>
  <Block>
    <Button fill>送信</Button>
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
