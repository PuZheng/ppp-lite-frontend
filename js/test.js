var formOpts = {
    fields: {
        name: {
            identifier: 'name',
            rules: [
                {
                    type: 'empty',
                    prompt: '名称不能为空'
                }
            ]
        },
        budget: {
            identifier: 'budget',
            rules: [
                {
                    type: 'empty',
                    prompt: '预算不能为空'
                },
                {
                    type: 'integer[1..999999999999999]',
                    prompt: '请输入大于0整数'
                }
            ]
        },
        description: {
            identifier: 'description',
            rules: [
                {
                    type: 'empty',
                    prompt: '描述不能为空'
                },
                {
                    type: 'maxLength[256]',
                    prompt: '最多256字'
                }
            ]
        },
    },
    inline: true,
    on: 'blur',
};
