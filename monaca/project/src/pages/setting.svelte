<Page name="setting">
  <Navbar title="GPSトラッカー（仮）設定" backLink="Back"></Navbar>
  <p class="mx">GPSトラッカーを設定する時はBluetoothをONにしてください。</p>
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
      <div><Button fill class="d-inline-block open-vertical">GPS</Button>　GPS00001　鈴木愛　未接続</div>
    </ListItem>
    <ListItem>
      <div><Button fill class="d-inline-block link" href="/setting-edit/">GPS</Button>　GPS00002</div>
    </ListItem>
    <ListItem>
      <div><Button fill class="d-inline-block">GPS</Button>　GPS00003</div>
    </ListItem>
  </List>
</Page>
<script>
  import {
    f7,
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

  import Dom7 from 'dom7';

Dom7(document).on('click', '.open-vertical', function () {
  f7.dialog.create({
    title: 'GPS00001',
    buttons: [
      {
        text: '再設定',
      },
      {
        text: '削除',
      }
    ],
    //verticalButtons: true,
    onClick: function(dialog, index){
      if(index == 0){
        openPair();
      }
    }
  }).open();
});

function openPair(){
  f7.dialog.create({
    title: 'GPS00001をペア設定しますか？',
    text: 'Bluetoothペア設定コード<br><span style="color: #cc0000; font-size: 26px">768131</span>',
    buttons: [
      {
        text: 'キャンセル',
      },
      {
        text: 'ペア設定する',
      }
    ],
  }).open();
}
</script>
