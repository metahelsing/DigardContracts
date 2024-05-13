const EldaruneItem = require("./data/EldaruneItem.json");
const fs = require("fs").promises;
const axios = require('axios');
const apiUrl = 'https://api-test.digard.io/api/GameItem/GetItemWithAttribute/';

async function fetchData(itemId) {
    let _apiUrl = apiUrl + String(itemId);
    const result = await axios.get(_apiUrl);
    if (result && result.data && result.data.data && result.data.data.attributes) {
        return result.data.data.attributes;
    }
    return [];
}
async function getChildData(k, l, {tokenId, image, name, description, attributes}){
    if(k => l) return;
    const subTimeOut = setTimeout(async () => {
        if(subTimeOut) clearTimeout(subTimeOut);
        attributes = JSON.parse(JSON.stringify(EldaruneItem[i].attributes));
        tokenId += 1;
        let _image = image + tokenId + ".png";
        let attribute = attributes.find((f) => f.trait_type == "Level");
        if (attribute) {
            attribute.value = String(k);
        }
        let itemId = EldaruneItem[i].itemIds[k - 1];
        fetchData(itemId).then(async (_extAttributes)=> {
            let _attributes = attributes.concat(_extAttributes);
            let result = {
                name: name,
                description: description,
                image: _image,
                attributes: _attributes
            };
            await fs.writeFile("./scripts/metadata/data/results/" + tokenId + ".json", JSON.stringify(result, null, 4));
            console.log("Write " + tokenId);
        });
        k++;
        getChildData(k,l);
    }, 2000);
}
async function getData(i) {
    if(i >= EldaruneItem.length) return;
    const timeOut = setTimeout(() => {
        if(timeOut) clearTimeout(timeOut);
        
        let itemId = EldaruneItem[i].itemIds[0];
        let tokenId = EldaruneItem[i].tokenId;
        const image = EldaruneItem[i].image;
        const name = EldaruneItem[i].name;
        const description = EldaruneItem[i].description;
        let attributes = JSON.parse(JSON.stringify(EldaruneItem[i].attributes));
        fetchData(itemId).then(async (extAttributes)=> {
            let _attributes = attributes.concat(extAttributes);
            let firstResult = {
                name: name,
                description: description,
                image: image + tokenId + ".png",
                attributes: _attributes
            };
            await fs.writeFile("./scripts/metadata/data/results/" + tokenId + ".json", JSON.stringify(firstResult, null, 4));
            await getChildData(2,11, {tokenId: tokenId, image: image, name: name, description: description, attributes: attributes});
        });
        i++;
        getData(i);
    }, 2000);
}
async function main() {
    getData(0);
}
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});