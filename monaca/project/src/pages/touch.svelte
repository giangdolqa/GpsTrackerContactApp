<Page name="touch">
  <Navbar title="接触確認" backLink="Back"></Navbar>
  <p class="mx">陽性者との接触の記録は14日間保存されます。</p>
  <List class="media-list">
    <ListItem>
      <div class="item-title">鈴木 愛 さん</div>
      <div class="item-subtitle">2020年11月10日から使用中</div>
      <div class="item-text">
        <Button fill class="link" href="/touch-ok/">陽性者との接触を確認する</Button>
      </div>
    </ListItem>
    <ListItem>
      <div class="item-title">鈴木 太郎 さん</div>
      <div class="item-subtitle">2020年11月10日から使用中</div>
      <div class="item-text">
        <Button fill class="link" href="/touch-ng/">陽性者との接触を確認する</Button>
      </div>
    </ListItem>
  </List>
  <Block>
    <p>新型コロナウイルスと診断されたら</p>
    <Button fill>陽性情報の登録</Button>
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
