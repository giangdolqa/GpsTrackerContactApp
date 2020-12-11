<Page name="touchNg">
  <Navbar title="鈴木愛さんの過去14日間の接触" backLink="Back"></Navbar>
  <p class="text-center"><Link iconIos="f7:info_round_fill" iconMd="material:info"/></p>
  <p class="mx">陽性者との接触が確認されました</p>
  <p class="text-center" style="color: #cc0000">3件</p>
  <Block>
    <p><Button fill>検査等の相談先を探す</Button></p>
    <p><Button fill class="link" href="/touch-list/">陽性者との接触一覧</Button></p>
    <p><Button fill class="link" href="/touch-report/">会社に報告</Button></p>
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
