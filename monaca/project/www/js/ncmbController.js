var application_key = "0fc8ef9ebeca54dc20bb817a75b7ceac933f395e21e3ec668e7971cad0302688";
var client_key = "b82f662f5b877024070a1f5a155a0390e53e68b0a27da3b1775dbbcb4a8ef419";

var ncmbController = {
    init: function() {
        var ncmb = new NCMB(application_key, client_key);
        var token = 'pk.eyJ1IjoiYmVsbGNvZGVyIiwiYSI6ImNraTgwNXkxMTAxMDcycm16bzBxaTFid2EifQ.TEHOeBb2fR2NVQVOm08pcw';
        navigator.geolocation.getCurrentPosition(function(location) {
            var map = L.map('map').setView([location.coords.latitude, location.coords.longitude], 15);
            L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token='+token, {
                attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                maxZoom: 18,
                id: 'gps-tracker',
                accessToken: token
            }).addTo(map);
        });
    }
};

document.addEventListener("DOMContentLoaded", function(event) { 
  ncmbController.init();
  
});