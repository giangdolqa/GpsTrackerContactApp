<Page name="Payment">
  <Navbar title="GPSトラッカー（仮）契約" backLink="Back"></Navbar>
  <List noHairlinesMd>
    <ListItem class="item-divider">鈴木一郎</ListItem>
    <ListInput
      label="期間"
      type="select"
      >
      <option>1年</option>
    </ListInput>
    <ListInput
      label="金額"
      type="text"
      value="3600"
      readonly
      >
      <option>1年</option>
    </ListInput>
    <ListInput
      label="お支払方法"
      type="select"
      >
      <option>クレジット</option>
    </ListInput>
  </List>
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
