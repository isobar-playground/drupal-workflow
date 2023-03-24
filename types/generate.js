const fs = require('fs');
const axios = require('axios');
const {compile} = require('json-schema-to-typescript');

const typesDir = './types';

async function fetchSchemasAndGenerateTypes() {
  try {
    const schema = await axios.get(process.env.JSON_API_SCHEMA_URL).catch((error) => {
      throw new Error(error.response.status + ' response from ' + process.env.JSON_API_SCHEMA_URL);
    })

    for await(const item of schema.data.allOf[1].links) {
      const targetSchema = await axios.get(item.targetSchema['$ref']);
      const resourceSchema = await axios.get(targetSchema.data.definitions.data.items['$ref']);
      const type = resourceSchema.data.definitions.type.const;

      const typeJson = await compile(resourceSchema.data, type);

      fs.writeFileSync('./types/' + type + '.ts', typeJson);
    }

  }
  catch (error) {
    console.error('An error occurred:', error);
  }
}

fetchSchemasAndGenerateTypes();
