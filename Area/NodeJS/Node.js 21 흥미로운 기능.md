---
tags: nodejs
---
[Node.js 21.0.0 릴리스: 새롭고 흥미로운 기능](https://medium.com/@devhoangkien?source=post_page-----e80ee7107692--------------------------------)

# 1. V8 JS 엔진 업데이트

```javascript
// Private class fields  
class MyClass {  
	#privateField = 42;  
	getPrivateField() {  
		return this.#privateField;  
	}  
}  
  
const myInstance = new MyClass();  
console.log(myInstance.getPrivateField()); // Output: 42
```

# 2. 안정적인 Fetch 및 WebStreams
```node
const fetch = require('node-fetch'); // Note that you still use 'require' for 'node-fetch'  
  
async function fetchData() {  
try {  
	const response = await fetch('https://jsonplaceholder.typicode.com/posts/1');  
	const data = await response.json();  
	console.log(data);  
	} catch (error) {  
	console.error(error);  
}  
}  
  
fetchData();
```

