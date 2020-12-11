<Page name="map">
<!--
  <Navbar sliding={false}>
    <NavLeft>
      <Link iconIos="f7:menu" iconAurora="f7:menu" iconMd="material:menu" panelOpen="left" />
    </NavLeft>
    <NavRight>
      <Link iconIos="f7:menu" iconAurora="f7:settings" iconMd="material:settings" href="/setting/" class="link"/>
    </NavRight>
  </Navbar>
  <Block>
  -->
  <div>
      <Link iconIos="f7:menu" iconAurora="f7:menu" iconMd="material:menu" panelOpen="left" />
  </div>
  <div id="viewDiv"></div>
  <!--
  <div id="map"></div>
  </Block>
  -->
</Page>
<script>
  import {
    Page,
    Navbar,
    NavTitle,
    NavRight,
    NavLeft,
    Link,
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
  
  console.log('map-page');
/*
  document.addEventListener("deviceready", function() {
    var div = document.getElementById("map");
    var map = plugin.google.maps.Map.getMap(div);
  }, false);
  */
</script>
