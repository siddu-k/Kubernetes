// Fetch data from Flask API
document.getElementById('dataBtn').addEventListener('click', async () => {
  const resultDiv = document.getElementById('dataResult');
  resultDiv.classList.add('active', 'loading');
  resultDiv.textContent = 'Loading...';

  try {
    const response = await fetch('/get-data');
    const data = await response.json();
    
    resultDiv.classList.remove('loading');
    resultDiv.classList.add('success');
    resultDiv.textContent = JSON.stringify(data, null, 2);
  } catch (error) {
    resultDiv.classList.remove('loading');
    resultDiv.classList.add('error');
    resultDiv.textContent = 'Error: ' + error.message;
  }
});

// Get greeting message
document.getElementById('greetBtn').addEventListener('click', async () => {
  const name = document.getElementById('nameInput').value.trim();
  
  if (!name) {
    alert('Please enter a name');
    return;
  }

  const resultDiv = document.getElementById('greetResult');
  resultDiv.classList.add('active', 'loading');
  resultDiv.textContent = 'Loading...';

  try {
    const response = await fetch(`/greet/${name}`);
    const data = await response.json();
    
    resultDiv.classList.remove('loading');
    resultDiv.classList.add('success');
    resultDiv.textContent = JSON.stringify(data, null, 2);
  } catch (error) {
    resultDiv.classList.remove('loading');
    resultDiv.classList.add('error');
    resultDiv.textContent = 'Error: ' + error.message;
  }
});

// Allow pressing Enter to submit
document.getElementById('nameInput').addEventListener('keypress', (e) => {
  if (e.key === 'Enter') {
    document.getElementById('greetBtn').click();
  }
});
