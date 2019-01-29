defmodule ExAliyunOts.MixinTest.Search do
  
  use ExUnit.Case
  use ExAliyunOts.Mixin

  require Logger
  alias ExAliyunOts.Const.Search.{ColumnReturnType, QueryType, SortOrder, SortType}
  require ColumnReturnType
  require QueryType
  require SortOrder
  require SortType

  @instance_name "edc-ex-test"
  @table_name "test_table"

  test "match query" do
    index_name = "test_search_index"
    result = 
      search @instance_name, @table_name, index_name,
        columns_to_get: {ColumnReturnType.specified, ["class", "name"]},
        #columns_to_get: ColumnReturnType.none,
        #columns_to_get: ColumnReturnType.all,
        #columns_to_get: ["class"],
        search_query: [
          query: [
            type: QueryType.match,
            field_name: "age",
            text: "28"
          ],
          limit: 1
        ]
    Logger.info "result: #{inspect result}"
  end

  test "term query" do
    index_name = "test_search_index2"
    result =
      search @instance_name, @table_name, index_name,
        search_query: [
          query: [
            type: QueryType.term,
            field_name: "age",
            term: 25
          ],
          limit: 1
        ]
    Logger.info "result: #{inspect result}"
  end

  test "terms query" do
    index_name = "test_search_index2"
    result =
      search @instance_name, @table_name, index_name,
        search_query: [
          query: [
            type: QueryType.terms,
            field_name: "age",
            terms: [28, 25]
          ],
          sort: [
            [type: SortType.field, field_name: "age", order: SortOrder.asc],
            [type: SortType.field, field_name: "name", order: SortOrder.asc]
          ]
        ]
    Logger.info "result: #{inspect result}"
  end

  test "prefix query" do
    index_name = "test_search_index2"
    result =
      search @instance_name, @table_name, index_name,
        search_query: [
          query: [
            type: QueryType.prefix,
            field_name: "name",
            prefix: "z"
          ],
          sort: [
            [type: SortType.field, field_name: "age", order: SortOrder.asc],
            [type: SortType.field, field_name: "name", order: SortOrder.asc]
          ]
        ],
        columns_to_get: ["age", "name"]
    Logger.info "result: #{inspect result}"
  end

  test "wildcard query" do
    index_name = "test_search_index2"
    result =
      search @instance_name, @table_name, index_name,
        search_query: [
          query: [
            type: QueryType.wildcard,
            field_name: "name",
            value: "z*"
          ],
          sort: [
            [type: SortType.field, field_name: "age", order: SortOrder.asc],
            [type: SortType.field, field_name: "name", order: SortOrder.asc]
          ]
        ],
        columns_to_get: ["age", "name"]
    Logger.info "result: #{inspect result}"
  end


end
