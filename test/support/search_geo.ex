defmodule ExAliyunOtsTest.Support.SearchGeo do

  require Logger

  alias ExAliyunOts.{Var, Client}
  alias ExAliyunOts.Var.Search
  alias ExAliyunOts.Const.{PKType, RowExistence}
  alias ExAliyunOts.Const.Search.FieldType
  require PKType
  require RowExistence
  require FieldType

  def init(instance_key, table, index_name) do
    create_table(instance_key, table)

    create_index(instance_key, table, index_name)

    insert_test_data(instance_key, table)
  end

  def clean(instance_key, table, index_name) do
    var_request = %Search.DeleteSearchIndexRequest{
      table_name: table,
      index_name: index_name
    }
    {:ok, _response} = Client.delete_search_index(instance_key, var_request)

    ExAliyunOts.Client.delete_table(instance_key, table)
    Logger.info "clean search_indexes and delete `#{table}` table"
  end

  defp create_table(instance_key, table) do
    var_create_table = %Var.CreateTable{
      table_name: table,
      primary_keys: [{"id", PKType.string}]
    }
    Client.create_table(instance_key, var_create_table)

    sleep = 3_000
    Logger.info "initialized table, waiting for #{sleep} ms"
    Process.sleep(sleep)
  end

  defp create_index(instance_key, table, index_name) do
    var_request =
      %Search.CreateSearchIndexRequest{
        table_name: table,
        index_name: index_name,
        index_schema: %Search.IndexSchema{
          field_schemas: [
            %Search.FieldSchema{
              field_name: "name"
            },
            %Search.FieldSchema{
              field_name: "location",
              field_type: FieldType.geo_point
            },
            %Search.FieldSchema{
              field_name: "value",
              field_type: FieldType.long
            }
          ]
        }
      }
    result = Client.create_search_index(instance_key, var_request)
    Logger.info "create_search_index for GEO test: #{inspect result}"

  end

  defp insert_test_data(instance_key, table) do

    data = [
      %{name: "a1", location: "0,0", value: 10},
      %{name: "a2", location: "10,10", value: 10},
      %{name: "a3", location: "13.41,30.41", value: 1},
      %{name: "a4", location: "5.14,5.21", value: 9},
      %{name: "a5", location: "4.31,2.91", value: 3},
      %{name: "a6", location: "0,-10", value: 4},
      %{name: "a7", location: "10,-4", value: 1},
      %{name: "a8", location: "10,20", value: 3},
      %{name: "a9", location: "10.1,30.45", value: 6},
      %{name: "a10", location: "3,10", value: 9}
    ]

    Enum.map(data, fn(item) ->
      attribute_columns = ExAliyunOts.Utils.attrs_to_row(item)
      var_put_row =
        %Var.PutRow{
          table_name: table,
          primary_keys: [{"id", item.name}],
          attribute_columns: attribute_columns,
          condition: %Var.Condition{
            row_existence: RowExistence.expect_not_exist
          }
        }

      {:ok, _result} = Client.put_row(instance_key, var_put_row)
    end)

    sleep = 25_000
    Logger.info "waiting #{sleep} ms for indexing..."
    Process.sleep(sleep)
  end

end
