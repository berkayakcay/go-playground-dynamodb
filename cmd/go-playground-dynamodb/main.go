package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/aws"

	"log"
	"time"

	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
)

var (
	tableName = "orders"
)

func main() {
	PrintParams()
	Separator()
	defaultConfig := Configure()
	client := dynamodb.NewFromConfig(defaultConfig)
	Separator()

	CreateTable(client)

	Separator()

	ListTables(client)

	Separator()

	Scan(client)

	Separator()

	ScanWithFilterExpressions(client)

	Separator()

	DeleteTable(client)

	Separator()

	ListTables(client)

	Separator()
}

func ScanWithFilterExpressions(client *dynamodb.Client) {

}

func Scan(client *dynamodb.Client) {
	scan, err := client.Scan(context.TODO(), &dynamodb.ScanInput{
		TableName: aws.String(tableName),
	})
	if err != nil {
		panic(err)
	}

	fmt.Println(scan.Items)
}

// DeleteTable deletes table.
func DeleteTable(client *dynamodb.Client) {
	table, err := client.DeleteTable(context.TODO(), &dynamodb.DeleteTableInput{
		TableName: aws.String(tableName),
	})
	if err != nil {
		panic(err)
	}

	fmt.Println(table)
}

// CreateTable creates table.
func CreateTable(client *dynamodb.Client) {
	input := &dynamodb.CreateTableInput{
		AttributeDefinitions: []types.AttributeDefinition{
			{
				AttributeName: aws.String("Vendor"),
				AttributeType: types.ScalarAttributeTypeS,
			},
			{
				AttributeName: aws.String("Order"),
				AttributeType: types.ScalarAttributeTypeS,
			},
		},
		KeySchema: []types.KeySchemaElement{
			{
				AttributeName: aws.String("Vendor"),
				KeyType:       types.KeyTypeHash,
			},
			{
				AttributeName: aws.String("Order"),
				KeyType:       types.KeyTypeRange,
			},
		},
		TableName: aws.String(tableName),
		//BillingMode:            "",
		//GlobalSecondaryIndexes: nil,
		//LocalSecondaryIndexes:  nil,
		ProvisionedThroughput: &types.ProvisionedThroughput{
			ReadCapacityUnits:  aws.Int64(5),
			WriteCapacityUnits: aws.Int64(5),
		},
		//SSESpecification:    nil,
		//StreamSpecification: nil,
		//TableClass:          "",
		//Tags:                nil,
	}

	table, err := client.CreateTable(context.TODO(), input)
	if err != nil {
		log.Fatalf("error on create table: %s", err)
	}

	fmt.Println(table.ResultMetadata)
}

// ListTables lists tables.
func ListTables(client *dynamodb.Client) {
	paginator := dynamodb.NewListTablesPaginator(client, nil, func(o *dynamodb.ListTablesPaginatorOptions) {
		o.StopOnDuplicateToken = true
	})

	for paginator.HasMorePages() {
		page, errPaginator := paginator.NextPage(context.TODO())
		if errPaginator != nil {
			panic(errPaginator)
		}

		for _, tableName := range page.TableNames {
			fmt.Println(tableName)
		}
	}
}

// Configure AWS.
func Configure() aws.Config {
	defaultConfig, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"),
		config.WithEndpointResolverWithOptions(aws.EndpointResolverWithOptionsFunc(
			func(service, region string, options ...interface{}) (aws.Endpoint, error) {
				return aws.Endpoint{URL: "http://localhost:8000"}, nil
			})),
		config.WithCredentialsProvider(credentials.StaticCredentialsProvider{
			Value: aws.Credentials{
				AccessKeyID:     "dummy",
				SecretAccessKey: "dummy",
				SessionToken:    "dummy",
				Source:          "Hard-coded credentials; values are irrelevant for local DynamoDB",
				CanExpire:       false,
				Expires:         time.Time{},
			},
		}))
	if err != nil {
		panic(err)
	}
	return defaultConfig
}

// Separator prints separator to console.
func Separator() {
	fmt.Println("# # # # # # # # # #")
}
