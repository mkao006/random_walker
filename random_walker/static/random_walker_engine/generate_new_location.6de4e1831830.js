// Function to generate a new destination
$(function() {
    $("#newLocationButton").on("click touchstart", function() {
	      $("#newLocationButton")
            .removeClass('btn-success')
            .addClass('btn-danger')
            .text('Generating Location!')
        $.ajax({
            // url: "{% url 'random_walker_engine:generate_new_destination' %}",
            url : "random_walker_engine:generate_new_destination",
            type: "POST",
            dataType: "json",
            data: JSON.stringify({'lat': parseFloat(map.getCenter()['lat']),
				                          'lng': parseFloat(map.getCenter()['lng']),
				                          'zoom': map.getZoom(),
				                          'boundne': map.getBounds().getNorthEast(),
				                          'boundsw': map.getBounds().getSouthWest(),
				                          'size': map.getSize(),
                                  'n_sample': 5}),
            success: function(data){
		            console.log("successful")
		            if(typeof circle !== 'undefined')
		                map.removeLayer(circle)
                if(typeof routingControl !== 'undefined')
                    map.removeControl(routingControl);
                // Add circle to the destination
                var circle_radius = 300 * Math.pow(2, 13 - map.getZoom())
		            circle = L.geoJson(data, {
			              pointToLayer: function(feature, latlng) {
			                  return new L.circle(latlng, circle_radius, {
                            color: 'red',
                            fillColor: '#f03',
                            fillOpacity: 0.5
                        })
			              }
		            });
		            map.addLayer(circle);
                // Add routing from home to the destination.
                var plan = new L.Routing.Plan(data, {
                    pointToRoute: function(feature, latlng){
                        return new L.latlng(latlng)
                    }
                })

                var plan2 = new L.Routing.Plan([
                    L.latLng(home),
                    L.latLng(data),
                    // Just testing
                    L.latLng(home[0] + Math.random(0.01), home[1] + Math.random(0.01))
                ])
                console.log(plan)
                console.log(plan2)

                routingControl = L.Routing.control({
                    plan: plan,
                    useZoomParameter: true,
                    show: false,
                    collapsible: false
                }).addTo(map);

		            $("#newLocationButton")
                    .addClass('btn-success')
                    .removeClass('btn-danger')
                    .text('Give Me A New Location!')
            },
            fail: function(data){
		            console.log("failed")
		            $("#newLocationButton")
                    .addClass('btn-success')
                    .removeClass('btn-danger')
                    .text('Give Me A New Location!')
            }
        })
    })
})
