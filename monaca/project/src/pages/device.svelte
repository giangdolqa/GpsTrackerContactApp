<Page name="device">
  <Navbar title="デバイス読込" backLink="Back"></Navbar>
  <p class="mx">GPSトラッカーからデータを読み込む時はBluetoothをONにしてください。</p>
  <List>
    <ListItem
      title="Bluetooth"
    >
      <span slot="after">
        <Toggle />
      </span>
    </ListItem>
    <ListItem class="item-divider">自分のデバイス</ListItem>
    <ListItem>
      <div><Button fill class="d-inline-block">GPS</Button>　鈴木愛　接続済み</div>
      <span class="after">
        <Link iconIos="f7:reload" iconMd="material:autorenew"/>
        <Link iconIos="f7:check_round_fill" iconMd="material:check_circle"/>
      </span>
    </ListItem>
    <ListItem>
      <div><Button fill class="d-inline-block">GPS</Button>　鈴木愛　接続済み</div>
      <span class="after">
        <Link iconIos="f7:reload" iconMd="material:autorenew"/>
        <Link iconIos="f7:check_round_fill" iconMd="material:check_circle"/>
      </span>
    </ListItem>
    <ListItem>
      <div><Button fill class="d-inline-block">GPS</Button>　鈴木愛　接続済み</div>
      <span class="after">
        <Link iconIos="f7:reload" iconMd="material:autorenew"/>
        <Link iconIos="f7:check_round_fill" iconMd="material:check_circle"/>
      </span>
    </ListItem>
  </List>
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
