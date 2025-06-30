import graphene
from graphene_django.types import DjangoObjectType
from .models import Service, Booking, Testimonial, Category


class CategoryType(DjangoObjectType):
    class Meta:
        model = Category


class ServiceType(DjangoObjectType):
    class Meta:
        model = Service


class BookingType(DjangoObjectType):
    class Meta:
        model = Booking


class TestimonialType(DjangoObjectType):
    class Meta:
        model = Testimonial


class Query(graphene.ObjectType):
    all_services = graphene.List(ServiceType)
    all_categories = graphene.List(CategoryType)
    service = graphene.Field(ServiceType, slug=graphene.String(required=True))

    def resolve_all_services(root, info):
        return Service.objects.select_related("category").all()

    def resolve_all_categories(root, info):
        return Category.objects.all()

    def resolve_service(root, info, slug):
        return Service.objects.select_related("category").get(slug=slug)


class CreateBooking(graphene.Mutation):
    class Arguments:
        service_id = graphene.ID(required=True)
        name = graphene.String(required=True)
        email = graphene.String(required=True)
        phone = graphene.String(required=True)
        participants = graphene.Int(required=True)
        date = graphene.types.datetime.Date(required=True)
        notes = graphene.String()

    booking = graphene.Field(BookingType)

    def mutate(self, info, service_id, name, email, phone, participants, date, notes=None):
        service = Service.objects.get(id=service_id)
        booking = Booking.objects.create(
            service=service,
            name=name,
            email=email,
            phone=phone,
            participants=participants,
            date=date,
            notes=notes
        )
        return CreateBooking(booking=booking)


class Mutation(graphene.ObjectType):
    create_booking = CreateBooking.Field()
