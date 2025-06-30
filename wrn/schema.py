import graphene
from services.schema import Query as ServicesQuery, Mutation as ServicesMutation

class Query(ServicesQuery, graphene.ObjectType):
    pass

class Mutation(ServicesMutation, graphene.ObjectType):
    pass

schema = graphene.Schema(query=Query, mutation=Mutation)
