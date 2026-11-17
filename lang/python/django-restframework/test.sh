#!/bin/sh

[ "$1" = "python3-django-restframework" ] || exit 0

python3 - << EOF
import sys
import importlib.metadata

version = importlib.metadata.version("djangorestframework")
if version != "$2":
    print("Wrong version: " + version)
    sys.exit(1)

# Bootstrap a minimal Django configuration
import django
from django.conf import settings
settings.configure(
    INSTALLED_APPS=[
        "django.contrib.contenttypes",
        "django.contrib.auth",
        "rest_framework",
    ],
    DATABASES={
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": ":memory:",
        }
    },
    ROOT_URLCONF=[],
    DEFAULT_AUTO_FIELD="django.db.models.BigAutoField",
)
django.setup()

# --- Serializer ---

from rest_framework import serializers

class BookSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=100)
    year = serializers.IntegerField(min_value=0)
    isbn = serializers.CharField(required=False, allow_blank=True)

# Valid data
s = BookSerializer(data={"title": "Two Scoops of Django", "year": 2023})
assert s.is_valid(), f"Serializer errors: {s.errors}"
assert s.validated_data["title"] == "Two Scoops of Django"
assert s.validated_data["year"] == 2023

# Invalid data
s2 = BookSerializer(data={"title": "", "year": -1})
assert not s2.is_valid()
assert "title" in s2.errors
assert "year" in s2.errors

# --- APIRequestFactory + APIView ---

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.test import APIRequestFactory
from rest_framework import status

class EchoView(APIView):
    def get(self, request):
        return Response({"method": "GET", "query": request.query_params.get("q", "")})

    def post(self, request):
        return Response({"received": request.data}, status=status.HTTP_201_CREATED)

factory = APIRequestFactory()

# GET
request = factory.get("/echo/", {"q": "hello"})
view = EchoView.as_view()
response = view(request)
response.accepted_renderer = __import__("rest_framework.renderers", fromlist=["JSONRenderer"]).JSONRenderer()
response.accepted_media_type = "application/json"
response.renderer_context = {}
assert response.status_code == 200
assert response.data["method"] == "GET"
assert response.data["query"] == "hello"

# POST
request = factory.post("/echo/", {"key": "value"}, format="json")
response = view(request)
assert response.status_code == 201
assert response.data["received"] == {"key": "value"}

# --- Status codes ---

assert status.HTTP_200_OK == 200
assert status.HTTP_201_CREATED == 201
assert status.HTTP_400_BAD_REQUEST == 400
assert status.HTTP_404_NOT_FOUND == 404
assert status.is_success(200)
assert status.is_client_error(400)
assert status.is_server_error(500)

# --- SimpleRouter ---

from rest_framework.routers import SimpleRouter
from rest_framework.viewsets import ViewSet

class NullViewSet(ViewSet):
    def list(self, request):
        return Response([])

router = SimpleRouter()
router.register(r"items", NullViewSet, basename="item")
urls = [u.name for u in router.urls]
assert "item-list" in urls, f"Expected item-list in {urls}"

sys.exit(0)
EOF
