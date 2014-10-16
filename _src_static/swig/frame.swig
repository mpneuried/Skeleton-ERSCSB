<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1.0, maximum-scale=1.0, minimal-ui" />
		<meta name="description" content="">
		<meta name="author" content="">

		<title>{{title}}</title>

		<!-- Bootstrap core CSS -->
		<link href="/css/external.css" rel="stylesheet">
		<!-- Custom styles for this template -->
		<link href="/css/style.css" rel="stylesheet">

		{% block header %}{% endblock %}
	</head>

	<body>

		<div class="headwrp" data-spy="affix" data-offset-top="30">
			<div class="container">
				<div class="header">
					<ul class="nav nav-pills pull-right">
						<li><a href="/index.html"><b>Link</b> <small>1</small></a></li>
						<li><a href="/index.html"><b>Link</b> <small>2</small></a></li>
					</ul>
					<h3 class="text-muted"><a href="/index.html">{{title}}</a></h3>
				</div>
				
			</div> <!-- /container -->

		</div>

		{% block body %}{% endblock %}

		
		<div class="footer">
			<div class="container ">
				<div class="row links">
					<div class="col-sm-4 col-xs-12"><a class="btn" href="/index.html" class="btn btn-link">{{title}} <small>left</small></a></div>
					<div class="col-sm-4 col-xs-12"><a class="btn" href="/index.html" class="btn btn-link">{{title}} <small>middle</small></a></div>
					<div class="col-sm-4 col-xs-12"><a class="btn" href="/index.html" class="btn btn-link">{{title}} <small>right</small></a></div>
				</div>
			</div>
		</div>
		
		<script src="/js/scripts.js?v={{version}}"></script>

	</body>
</html>