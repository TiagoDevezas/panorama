$(document).ready(function() {

	// $('.bar-chart').highcharts({
 //        chart: {
 //            type: 'bar'
 //        },
 //        title: {
 //            text: 'Fruit Consumption'
 //        },
 //        xAxis: {
 //            categories: ['Apples', 'Bananas', 'Oranges']
 //        },
 //        yAxis: {
 //            title: {
 //                text: 'Fruit eaten'
 //            }
 //        },
 //        series: [{
 //            name: 'Jane',
 //            data: [1, 0, 4]
 //        }, {
 //            name: 'John',
 //            data: [5, 7, 3]
 //        }]
 //    });

	var source = '';

	var query = '';

	var selectedSource = '';

	var timePeriod = '&by=day';

	var sourceData = '';

	var itemsData = '';

	var query = '';


	function onSearchSubmit() {
		value = $('input[type="search"]').val();
		query = value;
		var source = selectedSource;
		var sourceParam = source ? "&source=" + source : '';
		var searchParam = query !== '' ? "&q=" + query : '';
		$.get('/api/items?limit=15' + sourceParam + searchParam, function(data) {
			drawCharts(selectedSource);
			var textStatsDiv = $('.text-stats');
			textStatsDiv.html('');
			textStatsDiv.append(
				"<table class='articles full-width'>" +
				"<tbody>" +
					"<tr>" +
						"<th>Título</th>" +
						"<th>Fonte</th>" +
						"<th>Data de publicação</th>" +
						"<th>Partilhas</th>" +
					"</tr>" +
				"</tbody>" +
				"</table>"
				);
			$.each(data, function(key, value) {
				$('table.articles tbody').append(
						"<tr>" + 
							"<td><a href='" + value.url + "'>" + value.title + "</a></td>" +
							"<td>" + value.source + "</td>" +
							"<td>" + value.pub_date + "</td>" +
							"<td>" + value.total_shares + "</td>" +
						"</tr>"
					);
			});
		});
	}

	$('input[type="search"]').keypress(function(e) {
		if (e.which == 13) {
			onSearchSubmit();
			setHeader(selectedSource);
		}
	});

	$('.search-and-submit button[type="submit"]').on("click", function(e) {
		onSearchSubmit();
		setHeader(selectedSource);
	});

	$("input[type='radio']").on("click", function(){
		var value = $("input[type='radio']:checked").val();
		if(value == 'show-by-day') {
			timePeriod = '&by=day';
			drawCharts(selectedSource);			
		}
		if (value == 'show-by-hour') {
			timePeriod = '&by=hour';
			changeChart(selectedSource);	
		}
	})

	$('.source-select').change(function() {
		selectedSource = $('.source-select option:selected').text();
		$('.row.stats').remove();
		$.get('api/sources?name=' + selectedSource, function(data) {
			sourceData = data[0];
			newData = sourceData;
			drawCharts(selectedSource);
			setHeader(selectedSource);
			var keysToDelete = ['id', 'name', 'type', 'categories'];
			$.each(keysToDelete, function(e, v) {
				delete newData[v];
			});
			if(selectedSource) {
				$('.container').append("<div class='row stats'></div>");
				$.each(newData, function(key, value) {
					$('.row.stats').append(
						"<div class='chart-wrapper three-col'>" +
					    "<div class='chart-main'>" +
					      "<p class='value'>" +
					      	value +
					      "</p>" +
					    "</div>" +
					    "<div class='chart-footer'>" + key + "</div>" +
					  "</div>"
					)
				});
			}
		});
		query = '';
		$('input[type="search"]').val('');
	});

	drawCharts(selectedSource);

	function drawCharts(source) {
		drawTotalsCharts(source);
		drawPieChart(source);
		if (selectedSource === '') {
			setHeader('Todas');
		}
	}

	function drawTotalsCharts(source) {
		var source = source;
		var sourceParam = source ? "&source=" + source : '';
		var searchParam = query !== '' ? "&q=" + query : '';
		var chart = c3.generate({
			bindto: '.bar-chart',
			data: {
				x: 'time',
				url: 'api/totals?since=2014-10-15' + sourceParam + timePeriod + searchParam,
				mimeType: 'json',
				keys: {
					value: ['time', 'articles', 'twitter_shares', 'facebook_shares']
				},
				types: {
					articles: 'area',
					twitter_shares: 'area',
					facebook_shares: 'area'
				},
				names: {
					articles: 'Artigos Publicados',
					twitter_shares: 'Partilhas no Twitter',
					facebook_shares: 'Partilhas no Facebook'
				},
				//onclick: function(d, i) { changeChart(d, sourceParam); }
			},
			axis: {
				x: {
					type: 'timeseries',
					tick: {
						format: '%d %b'
					}
				}
			}
		});		
	}

	function drawPieChart(source) {
		var source = source;
		var sourceParam = source ? "?name=" + source : '';
		var searchParam = query !== '' ? "&q=" + query : '';
		var pieChart = c3.generate({
			bindto: '.pie-chart',
			data: {
				url: 'api/sources' + sourceParam + searchParam,
				mimeType: 'json',
				keys: {
					value: ['twitter_shares', 'facebook_shares']
				},
				names: {
					twitter_shares: 'Partilhas no Twitter',
					facebook_shares: 'Partilhas no Facebook'
				},
				type: 'pie'
			},
			pie: {
			label: {
				format: function(d) {
					return d;
				}
			}				
			}

		});
	}



	function formatDate(dateObj) {
		fullDate = dateObj;
		year = fullDate.getFullYear();
		month = fullDate.getMonth() + 1;
		if(month < 10) {
			month = '0' + month;
		}
		day = fullDate.getDate();
		if(day < 10) {
			day = '0' + day;
		}
		return "" + year + "-" + month + "-" + day +  ""
	}

	function setHeader(text) {
		if (text !== '') {
			$('.chart-title').html(text);
		}
	}

	function changeChart(source) {
		var source = source;
		var sourceParam = source ? "&source=" + source : '';
		var searchParam = query !== '' ? "&q=" + query : '';
		//dateObj = data.x;
		//startDate = formatDate(data.x);
		//endDate = new Date(dateObj.setDate(dateObj.getDate() + 1));
		//endDate = formatDate(endDate);
		c3.generate({
			bindto: '.bar-chart',
			data: {
				x: 'time',
				url: 'api/totals?since=2014-10-10' + sourceParam + timePeriod + searchParam,
				mimeType: 'json',
				keys: {
					value: ['time', 'articles', 'twitter_shares', 'facebook_shares']
				},
				types: {
					articles: 'area',
					twitter_shares: 'area',
					facebook_shares: 'area'
				},
				names: {
					articles: 'Artigos Publicados',
					twitter_shares: 'Partilhas no Twitter',
					facebook_shares: 'Partilhas no Facebook'
				},
			},
			axis: {
				x: {
					tick: {
						format: function(x) { 
							return x;
						}
					}
				}
			}
		});

	}

});