<Page name="settingEdit">
  <Navbar title="GPS00002設定" backLink="Back"></Navbar>
  <List noHairlinesMd>
    <ListInput
      label="名前"
      type="text"
      placeholder="鈴木次郎"
    ></ListInput>
    <ListInput
      label="性別"
      type="select"
      >
      <option>男の子</option>
      <option>女の子</option>
      <option>答えない</option>
    </ListInput>
    <ListInput
      label="年齢"
      type="text"
      placeholder="9"
    ></ListInput>
    <ListItem
      title="GPSトラッカー"
    >
      <span slot="after">
        <Toggle />
      </span>
    </ListItem>
    <ListInput
      label="キー"
      type="text"
      placeholder="********"
    ></ListInput>
    <ListItem
      checkbox
      name="my-checkbox"
      value="1"
      title="キーを表示"
    ></ListItem>
    <ListInput
      label="送信の間隔"
      type="select"
      >
      <option>2分</option>
    </ListInput>
    <ListItem
      title="追跡記録"
    >
      <span slot="after">
        <Toggle />
      </span>
    </ListItem>
    <ListInput
      label="認証コード"
      type="text"
      placeholder="0000-0000-0000"
    ></ListInput>
    <ListItem>
      <div> 2021年11月30日まで　<Button fill class="d-inline-block">認証コード取得</Button></div>
    </ListItem>
  </List>
  <Block>
    <Button fill class="link" href="/payment/">OK</Button>
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
