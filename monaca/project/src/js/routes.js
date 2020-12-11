
import HomePage from '../pages/home.svelte';
import FormPage from '../pages/form.svelte';
import CatalogPage from '../pages/catalog.svelte';
import ProductPage from '../pages/product.svelte';
import SettingsPage from '../pages/settings.svelte';

import DynamicRoutePage from '../pages/dynamic-route.svelte';
import RequestAndLoad from '../pages/request-and-load.svelte';
import NotFoundPage from '../pages/404.svelte';

import AuthPage from '../pages/auth.svelte';
import DevicePage from '../pages/device.svelte';
import LoginPage from '../pages/login.svelte';
import MapPage from '../pages/map.svelte';
import PaymentPage from '../pages/payment.svelte';
import PasswordPage from '../pages/password.svelte';
import RegisterPage from '../pages/register.svelte';
import SettingEditPage from '../pages/setting-edit.svelte';
import SettingPage from '../pages/setting.svelte';
import TouchListPage from '../pages/touch-list.svelte';
import TouchNgPage from '../pages/touch-ng.svelte';
import TouchOkPage from '../pages/touch-ok.svelte';
import TouchReportPage from '../pages/touch-report.svelte';
import TouchPage from '../pages/touch.svelte';

var routes = [
  {
    path: '/',
    component: MapPage,
  },
  {
    path: '/auth/',
    component: AuthPage,
  },
  {
    path: '/device/',
    component: DevicePage,
  },
  {
    path: '/login/',
    component: LoginPage,
  },
  {
    path: '/map/',
    //component: MapPage,
    async: function (routeTo, routeFrom, resolve, reject) {
      // Router instance
      var router = this;

      // App instance
      var app = router.app;

      // Show Preloader
      app.preloader.show();

      // User ID from request
      var userId = routeTo.params.userId;

      // Simulate Ajax Request
      setTimeout(function () {
/*
  	require([
  	  "esri/views/MapView",
  	  "esri/WebMap",
      "dojo/domReady!"
  	 ], function(MapView, WebMap) {

    	// Web マップの参照
    	var map = new WebMap({
        portalItem: {
          id: "d3ffea931f4a455f9c3b6c2102e66eda"
        }
      });

      // 地図ビュー
    	var view = new MapView({
        map: map,
        container: "viewDiv"
      });
     });
*/
        // We got user data from request
        var user = {
          firstName: 'Vladimir',
          lastName: 'Kharlampidi',
          about: 'Hello, i am creator of Framework7! Hope you like it!',
          links: [
            {
              title: 'Framework7 Website',
              url: 'http://framework7.io',
            },
            {
              title: 'Framework7 Forum',
              url: 'http://forum.framework7.io',
            },
          ]
        };
        // Hide Preloader
        app.preloader.hide();

        // Resolve route to load page
        resolve(
          {
            component: MapPage,
          },
          {
            context: {
            }
          }
        );
      }, 1000);
    },
  },
  {
    path: '/password/',
    component: PasswordPage,
  },
  {
    path: '/payment/',
    component: PaymentPage,
  },
  {
    path: '/register/',
    component: RegisterPage,
  },
  {
    path: '/setting-edit/',
    component: SettingEditPage,
  },
  {
    path: '/setting/',
    component: SettingPage,
  },
  {
    path: '/touch-list/',
    component: TouchListPage,
  },
  {
    path: '/touch-ng/',
    component: TouchNgPage,
  },
  {
    path: '/touch-ok/',
    component: TouchOkPage,
  },
  {
    path: '/touch-report/',
    component: TouchReportPage,
  },
  {
    path: '/touch/',
    component: TouchPage,
  },

  {
    path: '/home/',
    component: HomePage,
  },
  {
    path: '/form/',
    component: FormPage,
  },
  {
    path: '/catalog/',
    component: CatalogPage,
  },
  {
    path: '/product/:id/',
    component: ProductPage,
  },
  {
    path: '/settings/',
    component: SettingsPage,
  },

  {
    path: '/dynamic-route/blog/:blogId/post/:postId/',
    component: DynamicRoutePage,
  },
  {
    path: '/request-and-load/user/:userId/',
    async: function (routeTo, routeFrom, resolve, reject) {
      // Router instance
      var router = this;

      // App instance
      var app = router.app;

      // Show Preloader
      app.preloader.show();

      // User ID from request
      var userId = routeTo.params.userId;

      // Simulate Ajax Request
      setTimeout(function () {
        // We got user data from request
        var user = {
          firstName: 'Vladimir',
          lastName: 'Kharlampidi',
          about: 'Hello, i am creator of Framework7! Hope you like it!',
          links: [
            {
              title: 'Framework7 Website',
              url: 'http://framework7.io',
            },
            {
              title: 'Framework7 Forum',
              url: 'http://forum.framework7.io',
            },
          ]
        };
        // Hide Preloader
        app.preloader.hide();

        // Resolve route to load page
        resolve(
          {
            component: RequestAndLoad,
          },
          {
            context: {
              user: user,
            }
          }
        );
      }, 1000);
    },
  },
  {
    path: '(.*)',
    component: NotFoundPage,
  },
];

export default routes;
